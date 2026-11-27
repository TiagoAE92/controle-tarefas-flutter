// Representa uma tarefa e suas principais informações.
class TaskModel {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String prioridade;

  TaskModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    this.prioridade = 'Média',
  });

  // Cria uma cópia da tarefa permitindo alterar apenas alguns campos.
  TaskModel copyWith({
    String? titulo,
    String? descricao,
    bool? concluida,
    String? prioridade,
  }) {
    return TaskModel(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      prioridade: prioridade ?? this.prioridade,
    );
  }

  // Converte a tarefa para um mapa que pode ser salvo em JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'prioridade': prioridade,
    };
  }

  // Recupera uma tarefa a partir de um mapa de dados.
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] ?? false,
      prioridade: map['prioridade'] ?? 'Média',
    );
  }
}
