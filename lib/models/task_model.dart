class TaskModel {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;

  TaskModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  TaskModel copyWith({
    String? titulo,
    String? descricao,
    bool? concluida,
  }) {
    return TaskModel(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] ?? false,
    );
  }
}
