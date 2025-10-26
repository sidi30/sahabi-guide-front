# 🤖 Module Assistant Conversationnel

Module complet d'assistant conversationnel intelligent pour guider les utilisateurs à travers des étapes structurées.

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Configuration Backend](#configuration-backend)
- [Fonctionnalités](#fonctionnalités)
- [API Reference](#api-reference)

## 🎯 Vue d'ensemble

L'assistant conversationnel permet de :
- ✨ Guider les utilisateurs étape par étape via un chat interactif
- 💾 Fonctionner hors-ligne avec cache Hive
- 🔄 Synchroniser automatiquement les réponses avec le backend
- 🔔 Envoyer des notifications de rappel
- 📊 Suivre la progression utilisateur

## 🏗️ Architecture

```
features/assistant/
├── data/
│   ├── models/              # Modèles de données
│   │   ├── conversation_step_model.dart
│   │   ├── user_progress_model.dart
│   │   ├── chat_message_model.dart
│   │   └── session_model.dart
│   ├── datasources/         # Sources de données
│   │   ├── assistant_remote_data_source.dart
│   │   └── assistant_local_data_source.dart
│   └── services/            # Services métier
│       ├── bot_service.dart
│       ├── assistant_notification_service.dart
│       └── assistant_sync_service.dart
├── presentation/
│   ├── pages/               # Pages UI
│   │   └── assistant_chat_page.dart
│   ├── widgets/             # Widgets réutilisables
│   │   ├── chat_bubble.dart
│   │   ├── quick_reply_buttons.dart
│   │   └── typing_indicator.dart
│   └── providers/           # State management (Riverpod)
│       └── assistant_provider.dart
└── assistant_initializer.dart
```

## 🚀 Installation

### 1. Configuration Backend (Spring Boot)

Le backend fournit les APIs nécessaires :

**Endpoints disponibles :**
- `GET /api/v1/assistant/steps` - Liste des étapes
- `POST /api/v1/assistant/sessions/{userId}/start` - Démarrer session
- `POST /api/v1/assistant/progress/{userId}/answer` - Enregistrer réponse
- `POST /api/v1/assistant/progress/{userId}/sync` - Synchroniser offline
- `GET /api/v1/assistant/progress/{userId}` - Progression utilisateur

### 2. Configuration Flutter

**Dépendances requises** (déjà dans `pubspec.yaml`) :
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^17.2.3
  connectivity_plus: ^6.1.5
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
```

**Initialisation dans `main.dart` :**
```dart
import 'package:sahabi_guide/features/assistant/assistant_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise le module assistant
  await AssistantInitializer.initialize();
  
  runApp(const MyApp());
}
```

## 💡 Utilisation

### Afficher le chat assistant

```dart
import 'package:sahabi_guide/features/assistant/presentation/pages/assistant_chat_page.dart';

// Navigation vers l'assistant
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AssistantChatPage()),
);
```

### Personnalisation de l'URL API

Modifier dans `assistant_provider.dart` :
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseURL: 'https://votre-api.com/api/v1', // <- Votre URL
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  return dio;
});
```

### Récupérer l'userId authentifié

Modifier dans `assistant_provider.dart` :
```dart
final assistantChatProvider = StateNotifierProvider.autoDispose<
    AssistantChatNotifier, AsyncValue<AssistantChatState>>((ref) {
  
  // Récupérer depuis votre provider d'authentification
  final userId = ref.watch(authProvider).user?.id ?? 'default-user';
  
  // ...
});
```

## 🎨 Fonctionnalités

### 1. Types de questions supportés

- **YES_NO** : Questions Oui/Non avec boutons
- **MULTIPLE_CHOICE** : Choix multiples
- **TEXT** : Saisie libre
- **DATE** : Sélection de date
- **TIME** : Sélection d'heure

### 2. Mode Offline

- ✅ Toutes les étapes sont cachées localement
- ✅ Les réponses sont sauvegardées même sans connexion
- ✅ Synchronisation automatique dès que connexion disponible
- ✅ File d'attente de synchronisation

### 3. Notifications

- 🔔 Rappels programmés après X heures
- 🔔 Notification de bienvenue
- 🔔 Notification de fin
- 🔔 Notifications pour étapes critiques

### 4. Progression

- 📊 Statistiques de progression
- 📊 Nombre d'étapes complétées
- 📊 Pourcentage d'avancement
- 📊 Réponses non synchronisées

## 🔧 Configuration Backend

### Créer des étapes de conversation

Les étapes sont définies dans la base de données. Exemple de SQL pour insérer une étape :

```sql
INSERT INTO conversation_steps (
  id, step_code, step_order, question, question_ar, question_en,
  answer_type, answer_options_json, navigation_rules_json,
  next_step_code, is_critical, reminder_after_hours
) VALUES (
  gen_random_uuid(),
  'MINA_ARRIVAL',
  1,
  'Êtes-vous arrivé à Mina ?',
  'هل وصلت إلى منى؟',
  'Have you arrived at Mina?',
  'YES_NO',
  NULL,
  '{"YES": "ARAFAT_PREPARATION", "NO": "MINA_ARRIVAL", "default": "ARAFAT_PREPARATION"}',
  'ARAFAT_PREPARATION',
  true,
  24
);
```

### Seed de données

Créer un script SQL avec plusieurs étapes pour guider complètement l'utilisateur :

```sql
-- Étape 1
INSERT INTO conversation_steps (...);

-- Étape 2
INSERT INTO conversation_steps (...);

-- Etc.
```

## 📱 Captures d'écran (Conceptuel)

```
┌─────────────────────────────────┐
│ 🤖 Assistant Personnel    ⟳  ℹ️  │
├─────────────────────────────────┤
│                                 │
│  🤖 Bonjour ! Je suis votre    │
│     assistant personnel.        │
│     10:30                       │
│                                 │
│               Bonjour ! 👋      │
│               10:31         👤 │
│                                 │
│  🤖 Êtes-vous arrivé à Mina ?  │
│     10:32                       │
│                                 │
├─────────────────────────────────┤
│ Réponses suggérées              │
│ ┌─────────┐  ┌──────────┐      │
│ │ Oui  →  │  │  Non  →  │      │
│ └─────────┘  └──────────┘      │
└─────────────────────────────────┘
```

## 🧪 Tests

### Mode Debug

Pour tester avec des données mockées :

```dart
// TODO: Implémenter un mode debug
final isMockMode = true;

if (isMockMode) {
  // Utiliser des données de test
  final mockSteps = [
    ConversationStepModel(
      id: '1',
      stepCode: 'TEST_STEP_1',
      stepOrder: 1,
      question: 'Question de test ?',
      answerType: 'YES_NO',
    ),
  ];
}
```

## 🔒 Sécurité

- ✅ Authentification JWT (à configurer)
- ✅ Validation des entrées côté backend
- ✅ Stockage sécurisé local avec Hive
- ✅ Synchronisation chiffrée (HTTPS)

## 🐛 Troubleshooting

### Problème : "No steps found"
**Solution** : Vérifier que les étapes sont bien dans la base de données backend

### Problème : "Sync failed"
**Solution** : Vérifier la connexion réseau et l'URL de l'API

### Problème : "Notifications not showing"
**Solution** : Vérifier les permissions de notification dans les paramètres

## 📚 API Reference

### BotService

```dart
// Initialiser
await botService.initialize(userId);

// Démarrer session
await botService.startOrResumeSession();

// Générer message bot
final message = await botService.generateBotMessage();

// Enregistrer réponse
await botService.handleUserAnswer('Oui');

// Redémarrer conversation
await botService.restartConversation();

// Statistiques
final stats = await botService.getProgressStats();
```

### AssistantSyncService

```dart
// Sync automatique
await syncService.syncIfConnected();

// Force sync
await syncService.forceSyncNow();

// Full sync
await syncService.fullSync(userId);
```

## 🎯 Roadmap

- [ ] Support multi-langues complet (AR, EN, FR)
- [ ] Mode vocal (Speech-to-Text)
- [ ] Analytics et insights
- [ ] Export de la progression (PDF)
- [ ] Partage de conversation
- [ ] Thèmes personnalisables

## 🤝 Contribution

Ce module a été conçu pour être modulaire et extensible. N'hésitez pas à l'adapter selon vos besoins !

## 📄 License

Propriétaire - Sahabi Guide © 2024

