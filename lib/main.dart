
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

// Ponto de entrada do aplicativo Flutter.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuApp());
}

// Define o tema, o título e a tela inicial do aplicativo.
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

// Controla a navegação inicial conforme o estado da autenticação.
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

  // Verifica se existe uma sessão de usuário salva no dispositivo.
  Future<void> verificarLogin() async {
    final usuario = await auth.usuarioLogado();
    if (!mounted) return;
    setState(() {
      emailLogado = usuario?.email;
      carregando = false;
    });
  }

  // Atualiza a tela após a autenticação do usuário.
  void entrar(String email) {
    setState(() => emailLogado = email);
  }

  // Encerra a sessão e retorna para a tela de login.
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
