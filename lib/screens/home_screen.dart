import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final Future<void> Function() onLogout;

  const HomeScreen({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService banco = DatabaseService();
  List<TaskModel> tarefas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final lista = await banco.listar(widget.email);
    if (!mounted) return;
    setState(() {
      tarefas = lista;
      carregando = false;
    });
  }

  Future<void> abrirFormulario({TaskModel? tarefa}) async {
    final tituloController = TextEditingController(text: tarefa?.titulo ?? '');
    final descricaoController =
        TextEditingController(text: tarefa?.descricao ?? '');
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Digite um título.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      if (tarefa == null) {
        final nova = TaskModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim(),
        );
        await banco.adicionar(widget.email, nova);
      } else {
        final editada = tarefa.copyWith(
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim(),
        );
        await banco.atualizar(widget.email, editada);
      }
      await carregarTarefas();
    }

    tituloController.dispose();
    descricaoController.dispose();
  }

  Future<void> mudarStatus(TaskModel tarefa, bool? valor) async {
    await banco.atualizar(
      widget.email,
      tarefa.copyWith(concluida: valor ?? false),
    );
    await carregarTarefas();
  }

  Future<void> excluir(TaskModel tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await banco.excluir(widget.email, tarefa.id);
      await carregarTarefas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : tarefas.isEmpty
              ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tarefas.length,
                  itemBuilder: (context, indice) {
                    final tarefa = tarefas[indice];
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: tarefa.concluida,
                          onChanged: (valor) => mudarStatus(tarefa, valor),
                        ),
                        title: Text(
                          tarefa.titulo,
                          style: TextStyle(
                            decoration: tarefa.concluida
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: tarefa.descricao.isEmpty
                            ? null
                            : Text(tarefa.descricao),
                        onTap: () => abrirFormulario(tarefa: tarefa),
                        trailing: IconButton(
                          tooltip: 'Excluir',
                          onPressed: () => excluir(tarefa),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
