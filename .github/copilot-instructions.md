# Instruções do Copilot para o Projeto Semana da Computação DECSI

## Visão Geral do Projeto
Sistema em Flutter para a Semana da Computação do DECSI com funcionalidades de:
- Check-in de participantes
- Programação de eventos
- Agenda personalizada
- Sistema de perguntas

## Convenções de Código

### Dart/Flutter
- Use CamelCase para classes e tipos
- Use snake_case para variáveis, métodos e arquivos
- Sempre adicione documentação com comentários `///`
- Use `const` constructors quando possível
- Implemente proper error handling com try-catch

### Estrutura de Arquivos
```
lib/
├── models/        # Modelos de dados (Participant, Event, etc)
├── screens/       # Telas da aplicação
├── widgets/       # Componentes reutilizáveis
├── theme/         # Tema e estilos
├── services/      # Serviços (API, storage local)
└── main.dart      # Ponto de entrada
```

## Gerenciamento de Estado
- Use Provider para gerenciamento de estado
- Crie classes ChangeNotifier para cada seção de estado
- Mantenha o estado em `lib/models/app_state.dart`

## Padrões de Design
- Use padrões MVC/MVVM
- Separe lógica de negócio da UI
- Reutilize widgets quando possível

## Boas Práticas
1. Mantenha o código DRY (Don't Repeat Yourself)
2. Adicione comentários para lógica complexa
3. Use null-safety consistently
4. Implemente testes para funcionalidades críticas
5. Siga as recomendações do Flutter Best Practices Guide

## Dependências
- provider: ^6.0.0
- http: ^1.1.0
- intl: ^0.19.0
- table_calendar: ^3.0.0
- qr_flutter: ^4.1.0
- shared_preferences: ^2.2.2

## Antes de Começar
- Instale Flutter SDK 3.0.0+
- Configure um emulador Android ou iOS
- Crie a pasta `assets/images` e `assets/icons` para mídia

## Próximas Etapas Implementar
1. Tela de check-in com validação
2. Tela de programação com filtros
3. Integração com API backend
4. Sistema de notificações
5. Sincronização de dados local/remoto
