import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class DatabaseService {
  String _chave(String email) => 'tarefas_${email.toLowerCase()}';

  Future<List<TaskModel>> listar(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chave(email));
    if (dados == null) return [];

    final lista = jsonDecode(dados) as List;
    return lista
        .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _salvar(String email, List<TaskModel> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave(email),
      jsonEncode(tarefas.map((tarefa) => tarefa.toMap()).toList()),
    );
  }

  Future<void> adicionar(String email, TaskModel tarefa) async {
    final tarefas = await listar(email);
    tarefas.add(tarefa);
    await _salvar(email, tarefas);
  }

  Future<void> atualizar(String email, TaskModel tarefaAtualizada) async {
    final tarefas = await listar(email);
    final indice = tarefas.indexWhere((item) => item.id == tarefaAtualizada.id);
    if (indice == -1) return;

    tarefas[indice] = tarefaAtualizada;
    await _salvar(email, tarefas);
  }

  Future<void> excluir(String email, String id) async {
    final tarefas = await listar(email);
    tarefas.removeWhere((item) => item.id == id);
    await _salvar(email, tarefas);
  }
}
