import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final AuthService auth = AuthService();
  bool carregando = true;
  String? emailLogado;

  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    final usuario = await auth.usuarioLogado();
    if (!mounted) return;
    setState(() {
      emailLogado = usuario?.email;
      carregando = false;
    });
  }

  void entrar(String email) {
    setState(() => emailLogado = email);
  }

  Future<void> sair() async {
    await auth.logout();
    if (!mounted) return;
    setState(() => emailLogado = null);
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (emailLogado == null) {
      return LoginScreen(onLogin: entrar);
    }

    return HomeScreen(email: emailLogado!, onLogout: sair);
  }
}
