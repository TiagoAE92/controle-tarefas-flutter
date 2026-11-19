# Controle de Tarefas

Aplicativo simples de lista de tarefas desenvolvido em Flutter e Dart. O usuário cria uma conta, entra no aplicativo e pode organizar suas tarefas.

## Funcionalidades

- Cadastro de usuário com nome, e-mail e senha.
- Login e logout.
- Validação de campos obrigatórios e formato básico de e-mail.
- Proteção da tela principal: sem login, o usuário permanece na tela de entrada.
- Criar, listar, editar e excluir tarefas.
- Marcar tarefas como concluídas.
- Dados separados por usuário e mantidos após fechar o aplicativo.

## Tecnologias

- Flutter
- Dart
- `shared_preferences` para armazenamento local simples em formato JSON.

## Estrutura

```text
lib/
├── main.dart
├── models/
│   ├── task_model.dart
│   └── user_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
└── services/
    ├── auth_service.dart
    └── database_service.dart
```

## Como executar

1. Instale o Flutter e configure um emulador Android ou conecte um celular com depuração USB.
2. Abra o terminal na pasta do projeto.
3. Execute:

```bash
flutter doctor
flutter pub get
flutter run
```

Para verificar problemas de análise:

```bash
flutter analyze
```

## Autenticação e armazenamento

O `AuthService` faz o cadastro e a validação do login. Os usuários ficam salvos localmente usando `shared_preferences`. O e-mail do usuário conectado também é salvo para manter a sessão quando o aplicativo for aberto novamente.

O `DatabaseService` salva as tarefas em JSON. Cada usuário possui uma chave de armazenamento própria, formada pelo e-mail, evitando misturar as listas de tarefas.

## Observação importante

Este projeto usa autenticação local apenas para fins didáticos. As senhas são armazenadas localmente sem criptografia e não há servidor ou proteção contra acesso aos dados do dispositivo. Para um aplicativo real, use autenticação segura e um banco de dados/backend apropriado.
