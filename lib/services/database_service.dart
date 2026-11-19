import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

// Gerencia o armazenamento e a consulta das tarefas de cada usuário.
class DatabaseService {
  String _chave(String email) => 'tarefas_${email.toLowerCase()}';

  // Recupera todas as tarefas associadas ao e-mail informado.
  Future<List<TaskModel>> listar(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chave(email));
    if (dados == null) return [];

    final lista = jsonDecode(dados) as List;
    return lista
        .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Salva a lista atualizada de tarefas no armazenamento local.
  Future<void> _salvar(String email, List<TaskModel> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave(email),
      jsonEncode(tarefas.map((tarefa) => tarefa.toMap()).toList()),
    );
  }

  // Adiciona uma nova tarefa à lista do usuário.
  Future<void> adicionar(String email, TaskModel tarefa) async {
    final tarefas = await listar(email);
    tarefas.add(tarefa);
    await _salvar(email, tarefas);
  }

  // Substitui os dados de uma tarefa já existente.
  Future<void> atualizar(String email, TaskModel tarefaAtualizada) async {
    final tarefas = await listar(email);
    final indice = tarefas.indexWhere((item) => item.id == tarefaAtualizada.id);
    if (indice == -1) return;

    tarefas[indice] = tarefaAtualizada;
    await _salvar(email, tarefas);
  }

  // Remove da lista a tarefa identificada pelo seu código.
  Future<void> excluir(String email, String id) async {
    final tarefas = await listar(email);
    tarefas.removeWhere((item) => item.id == id);
    await _salvar(email, tarefas);
  }
}
