// Representa os dados de um usuário cadastrado no aplicativo.
class UserModel {
  final String nome;
  final String email;
  final String senha;

  UserModel({
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Converte os dados do usuário para o formato usado no armazenamento.
  Map<String, dynamic> toMap() {
    return {'nome': nome, 'email': email, 'senha': senha};
  }

  // Cria um usuário a partir dos dados recuperados do armazenamento.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
    );
  }
}
