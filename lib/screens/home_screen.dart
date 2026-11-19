import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

// Tela principal que apresenta e permite gerenciar as tarefas do usuário.
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

  // Atualiza a lista de tarefas exibida na tela.
  Future<void> carregarTarefas() async {
    final lista = await banco.listar(widget.email);
    if (!mounted) return;

    setState(() {
      tarefas = lista;
      carregando = false;
    });
  }

  // Abre o formulário para cadastrar uma tarefa ou editar uma existente.
  Future<void> abrirFormulario({TaskModel? tarefa}) async {
    final resultado = await showDialog<TaskModel>(
      context: context,
      builder: (dialogContext) {
        return _TaskFormDialog(tarefa: tarefa);
      },
    );

    if (!mounted || resultado == null) return;

    if (tarefa == null) {
      await banco.adicionar(widget.email, resultado);
    } else {
      await banco.atualizar(widget.email, resultado);
    }

    if (!mounted) return;
    await carregarTarefas();
  }

  // Altera a situação da tarefa entre concluída e pendente.
  Future<void> mudarStatus(TaskModel tarefa, bool? valor) async {
    await banco.atualizar(
      widget.email,
      tarefa.copyWith(concluida: valor ?? false),
    );

    if (!mounted) return;
    await carregarTarefas();
  }

  // Solicita confirmação e remove a tarefa selecionada.
  Future<void> excluir(TaskModel tarefa) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;

    await banco.excluir(widget.email, tarefa.id);

    if (!mounted) return;
    await carregarTarefas();
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

// Formulário utilizado para criar uma tarefa ou alterar seus dados.
class _TaskFormDialog extends StatefulWidget {
  final TaskModel? tarefa;

  const _TaskFormDialog({this.tarefa});

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.tarefa?.titulo ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.tarefa?.descricao ?? '',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  // Valida os campos e devolve os dados preenchidos para a tela principal.
  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final tarefaOriginal = widget.tarefa;

    final tarefa = TaskModel(
      id: tarefaOriginal?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      concluida: tarefaOriginal?.concluida ?? false,
    );

    Navigator.of(context).pop(tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Digite um título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
