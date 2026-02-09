# Semana da Computação DECSI - Aplicativo Flutter

Sistema de gerenciamento para a Semana da Computação do DECSI com funcionalidades de check-in, programação de eventos, agenda personalizada e envio de perguntas.

## 📋 Visão Geral do Projeto

Este aplicativo foi desenvolvido como projeto prático para a disciplina de **Gerenciamento de Projetos de Software**, demonstrando boas práticas de:
- ✅ Arquitetura limpa (separação de responsabilidades)
- ✅ Gerenciamento de estado com Provider
- ✅ Persistência local com shared_preferences
- ✅ Testes unitários automatizados
- ✅ Documentação de código

### Funcionalidades Principais

- ✅ **Check-in de Participantes**: Registro com validação de e-mail
- 📅 **Programação de Eventos**: Lista completa de eventos 
- 📍 **Agenda Personalizada**: Adicionar/remover eventos de interesse
- ❓ **Sistema de Perguntas**: Enviar e visualizar perguntas
- 👤 **Perfil do Usuário**: Informações do participante logado
- 💾 **Persistência Local**: Dados salvos automaticamente no dispositivo

## 🏗️ Arquitetura

```
lib/
├── main.dart                        # Ponto de entrada
├── models/
│   ├── app_state.dart              # Estado global (Provider)
│   ├── participant.dart            # Modelo de Participante
│   └── event.dart                  # Modelo de Evento
├── screens/
│   ├── home_screen.dart            # Tela principal (hub)
│   ├── checkin_screen.dart         # Check-in
│   ├── event_list_screen.dart      # Lista de eventos
│   ├── event_detail_screen.dart    # Detalhes do evento
│   ├── schedule_screen.dart        # Minha agenda
│   ├── questions_screen.dart       # Enviar perguntas
│   └── profile_screen.dart         # Perfil do usuário
└── theme/
    └── app_theme.dart              # Tema e estilos

test/
├── models/
│   └── app_state_test.dart         # Testes unitários
└── widget_test.dart                # Testes básicos
```

## 🛠️ Tecnologias

- **Framework**: Flutter 3.0+
- **Linguagem**: Dart 3.0+
- **Gerenciamento de Estado**: Provider ^6.0.0
- **Persistência**: shared_preferences ^2.2.2
- **Testes**: flutter_test + mocktail ^1.0.0

## 🚀 Guia de Configuração

### Pré-requisitos

- Flutter SDK 3.0.0+
- Dart 3.0.0+

### Instalação

```bash
# Baixe as dependências
flutter pub get

# Limpe builds anteriores (opcional)
flutter clean
```

### Executar a Aplicação

```bash
# Para Web (Chrome)
flutter run -d chrome

# Para Windows (Desktop)
flutter run -d windows

# Para Android
flutter run -d android-emulator

# Para iOS
flutter run -d iphone
```

### 🧪 Rodando Testes

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/models/app_state_test.dart

# Com cobertura
flutter test --coverage
```

## 📊 Fluxo de Dados (State Management)

```
AppState (ChangeNotifier)
    ├── bool isCheckedIn
    ├── Participant? currentParticipant
    ├── List<Event> events
    ├── List<Event> personalizedSchedule
    └── List<String> questions
         ↓
    SharedPreferences (Persistência local)
         ↓
    UI Screens (Provider.Consumer)
```

## 🧪 Testes Unitários

O projeto inclui cobertura completa de testes para `AppState`:

- ✅ Check-in / Check-out de participantes
- ✅ Adição / Remoção de eventos
- ✅ Gerenciamento de agenda personalizada
- ✅ Envio de perguntas
- ✅ Notificação de listeners (ChangeNotifier)
- ✅ Validação de dados

### Executar:
```bash
flutter test test/models/app_state_test.dart
```

## 💾 Persistência Local

Dados salvos em `shared_preferences`:

- `current_participant` - JSON do participante
- `events` - JSON array de eventos
- `personalized_schedule` - IDs dos eventos na agenda
- `questions` - JSON array de perguntas

## 🎨 Tema e Estilos

Todos os estilos centralizados em `lib/theme/app_theme.dart` para consistência visual.

## ✅ Boas Práticas Implementadas

### Código
- ✅ Null safety completo
- ✅ Validação de entrada
- ✅ Tratamento de exceções
- ✅ Documentação com `///`
- ✅ Separação de responsabilidades

### Testes
- ✅ Cobertura de casos principais
- ✅ Testes isolados (sem dependências externas)
- ✅ Estrutura Arrange-Act-Assert
- ✅ Nomenclatura descritiva

### State Management
- ✅ Provider centralizado
- ✅ ChangeNotifier para reatividade
- ✅ Consumer para uso em UI

## 📈 Próximas Melhorias

### Curto prazo
- [ ] Testes de widget (UI)
- [ ] Integração com API backend
- [ ] Dark mode
- [ ] Mais eventos de exemplo

### Médio prazo
- [ ] Autenticação (Firebase Auth)
- [ ] Notificações push
- [ ] QR code para check-in
- [ ] Internacionalização (i18n)

### Longo prazo
- [ ] Sincronização em tempo real
- [ ] Analytics (Firebase / Sentry)
- [ ] Responsividade avançada
- [ ] Publicação em App Stores

## 📝 Convenções de Código

- **Classes/Tipos**: `PascalCase` (ex: `AppState`, `Event`)
- **Funções/Variáveis**: `camelCase` (ex: `checkIn`, `currentParticipant`)
- **Constantes privadas**: `_kNome` (ex: `_kParticipantKey`)
- **Arquivos**: `snake_case` (ex: `app_state.dart`)
- **Comentários privados**: `///` para públicos, `//` para privados

## 🔐 Segurança

- ✅ Validação de entrada (e-mails, campos obrigatórios)
- ✅ Tratamento de exceções em operações assíncronas
- ✅ Sem armazenamento de dados sensíveis em plain text
- ✅ Null safety em todo o código

## 📞 Desenvolvimento

Para contribuir:

1. Crie uma branch (`git checkout -b feature/sua-feature`)
2. Commit mudanças (`git commit -am 'Add feature'`)
3. Push (`git push origin feature/sua-feature`)
4. Abra um Pull Request

## 📜 Licença

Projeto acadêmico - Uso livre para fins educacionais.

---

**Desenvolvido para: Gerenciamento de Projetos de Software**  
**Evento: Semana da Computação DECSI - UFMG**

### Propósito
Criar uma aplicação mobile que centralize informações e funcionalidades da Semana da Computação do DECSI, melhorando a experiência dos participantes.

### Objetivos
- Facilitar o check-in dos participantes
- Disponibilizar a programação completa do evento
- Permitir a personalização da agenda
- Habilitar a comunicação entre participantes e palestrantes

### Restrições
- **Orçamento**: Limitado
- **Tempo**: Desenvolvimento dentro do período da disciplina
- **Recursos**: Equipe de desenvolvimento limitada

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.

## Contato

Para dúvidas ou sugestões, entre em contato com o time de desenvolvimento.
