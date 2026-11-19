import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Reúne as operações de cadastro, login e encerramento de sessão.
class AuthService {
  static const String chaveUsuarios = 'usuarios';
  static const String chaveLogin = 'usuario_logado';

  // Busca a lista de usuários salva no dispositivo.
  Future<List<UserModel>> _lerUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(chaveUsuarios);

    if (dados == null) return [];

    final lista = jsonDecode(dados) as List;
    return lista
        .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Cadastra um usuário e impede o uso de um e-mail já registrado.
  Future<String?> cadastrar(UserModel usuario) async {
    final usuarios = await _lerUsuarios();

    final existe = usuarios.any(
      (item) => item.email.toLowerCase() == usuario.email.toLowerCase(),
    );

    if (existe) return 'Este e-mail já está cadastrado.';

    usuarios.add(usuario);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      chaveUsuarios,
      jsonEncode(usuarios.map((item) => item.toMap()).toList()),
    );
    return null;
  }

  // Confere as credenciais e registra o usuário autenticado.
  Future<String?> login(String email, String senha) async {
    final usuarios = await _lerUsuarios();

    UserModel? encontrado;
    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == email.toLowerCase() &&
          usuario.senha == senha) {
        encontrado = usuario;
        break;
      }
    }

    if (encontrado == null) return 'E-mail ou senha incorretos.';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chaveLogin, encontrado.email);
    return null;
  }

  // Retorna os dados do usuário que possui uma sessão ativa.
  Future<UserModel?> usuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(chaveLogin);
    if (email == null) return null;

    final usuarios = await _lerUsuarios();
    for (final usuario in usuarios) {
      if (usuario.email.toLowerCase() == email.toLowerCase()) {
        return usuario;
      }
    }
    return null;
  }

  // Remove a identificação da sessão atual.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chaveLogin);
  }
}
