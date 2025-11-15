# 🤖 Guide d'Implémentation - Assistant Conversationnel Intelligent

## 📋 Vue d'ensemble

Ce document décrit l'implémentation complète d'un assistant conversationnel pour l'application Sahabi Guide, construit avec **Flutter** (frontend) et **Spring Boot** (backend).

## 🎯 Fonctionnalités Principales

✅ **Conversation guidée** : Guide l'utilisateur étape par étape  
✅ **Hors-ligne** : Fonctionne sans connexion via Hive  
✅ **Synchronisation automatique** : Upload des réponses dès connexion disponible  
✅ **Notifications locales** : Rappels programmés  
✅ **Interface moderne** : Chat fluide avec animations  
✅ **Multi-langues** : Support FR, AR, EN  

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                  FLUTTER APP                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │        Presentation Layer                │  │
│  │  - AssistantChatPage (UI)               │  │
│  │  - ChatBubble, QuickReplyButtons        │  │
│  │  - AssistantProvider (Riverpod)         │  │
│  └──────────────────────────────────────────┘  │
│                      ↕                          │
│  ┌──────────────────────────────────────────┐  │
│  │          Business Layer                  │  │
│  │  - BotService (logique conversation)    │  │
│  │  - SyncService (synchronisation)        │  │
│  │  - NotificationService (rappels)        │  │
│  └──────────────────────────────────────────┘  │
│                      ↕                          │
│  ┌──────────────────────────────────────────┐  │
│  │           Data Layer                     │  │
│  │  - AssistantLocalDataSource (Hive)      │  │
│  │  - AssistantRemoteDataSource (API)      │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
                      ↕  HTTP REST
┌─────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND                │
├─────────────────────────────────────────────────┤
│  - AssistantController (REST API)              │
│  - AssistantService (logique métier)           │
│  - Repositories (JPA)                          │
│  - PostgreSQL Database                         │
└─────────────────────────────────────────────────┘
```

## 📦 Structure des Fichiers

### Backend (Spring Boot)

```
sahabi-guide-api/src/main/java/.../assistant/
├── domain/
│   ├── ConversationStep.java
│   ├── UserConversationProgress.java
│   └── ConversationSession.java
├── infra/
│   ├── ConversationStepRepository.java
│   ├── UserConversationProgressRepository.java
│   └── ConversationSessionRepository.java
├── app/
│   └── AssistantService.java
├── api/
│   ├── AssistantController.java
│   └── dto/
│       ├── ConversationStepDto.java
│       ├── UserProgressDto.java
│       ├── SessionDto.java
│       ├── AnswerRequest.java
│       └── SyncRequest.java
└── ...

scripts/
└── seed_conversation_steps.sql
```

### Frontend (Flutter)

```
lib/features/assistant/
├── data/
│   ├── models/
│   │   ├── conversation_step_model.dart
│   │   ├── user_progress_model.dart
│   │   ├── chat_message_model.dart
│   │   └── session_model.dart
│   ├── datasources/
│   │   ├── assistant_remote_data_source.dart
│   │   └── assistant_local_data_source.dart
│   └── services/
│       ├── bot_service.dart
│       ├── assistant_notification_service.dart
│       └── assistant_sync_service.dart
├── presentation/
│   ├── pages/
│   │   └── assistant_chat_page.dart
│   ├── widgets/
│   │   ├── chat_bubble.dart
│   │   ├── quick_reply_buttons.dart
│   │   └── typing_indicator.dart
│   └── providers/
│       └── assistant_provider.dart
├── assistant_initializer.dart
└── README.md
```

## 🚀 Installation et Configuration

### 1. Backend (Spring Boot)

#### Créer les tables

Exécutez le script SQL :

```bash
cd sahabi-guide-api/scripts
psql -U your_user -d sahabi_guide -f seed_conversation_steps.sql
```

Ou via Liquibase (recommandé) :

Créer un changeset dans `src/main/resources/db/changelog/` :

```xml
<changeSet id="create-assistant-tables" author="dev">
    <sqlFile path="db/changelog/scripts/seed_conversation_steps.sql"/>
</changeSet>
```

#### Vérifier les dépendances Maven

Dans `pom.xml`, assurez-vous d'avoir :

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
    </dependency>
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
    </dependency>
</dependencies>
```

#### Configurer application.yml

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/sahabi_guide
    username: your_user
    password: your_password
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

#### Démarrer le serveur

```bash
cd sahabi-guide-api
./mvnw spring-boot:run
```

Les APIs seront disponibles sur `http://localhost:8080/api/v1/assistant/`

### 2. Frontend (Flutter)

#### Installer les dépendances

Toutes les dépendances nécessaires sont déjà dans `pubspec.yaml`.

```bash
cd sahabi-guide-front
flutter pub get
```

#### Générer les adapters Hive

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Configurer l'URL de l'API

Dans `lib/features/assistant/presentation/providers/assistant_provider.dart` :

```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseURL: 'http://votre-serveur:8080/api/v1', // <- Modifier ici
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  return dio;
});
```

#### Initialiser dans main.dart

```dart
import 'package:sahabi_guide/features/assistant/assistant_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise le module assistant
  await AssistantInitializer.initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

#### Ajouter la navigation

```dart
// Dans votre menu ou page d'accueil
import 'package:sahabi_guide/features/assistant/presentation/pages/assistant_chat_page.dart';

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssistantChatPage()),
    );
  },
  child: const Text('🤖 Assistant'),
)
```

## 📱 Utilisation

### Interface utilisateur

L'interface se compose de :

1. **Zone de messages** : Affiche l'historique de conversation
   - Bulles du bot (à gauche, grises)
   - Bulles utilisateur (à droite, colorées)

2. **Boutons de réponse rapide** : Pour les questions YES_NO ou MULTIPLE_CHOICE
   - Apparaissent au-dessus du clavier
   - Désactivés pendant le traitement

3. **Zone de saisie** : Pour les questions TEXT, DATE, TIME
   - Champ de texte + bouton d'envoi

4. **Barre d'outils** :
   - Recommencer (🔄)
   - Statistiques (ℹ️)

### Flux de conversation

```
1. Utilisateur ouvre l'assistant
2. Bot : "Bienvenue ! Êtes-vous prêt ?"
3. Utilisateur : [Oui]
4. Bot : "Avez-vous effectué le Ghusl ?"
5. Utilisateur : [Oui]
6. Bot : "Avez-vous formulé l'intention ?"
... et ainsi de suite
```

### Gestion hors-ligne

- ✅ Les réponses sont sauvegardées localement
- ✅ Synchronisation automatique dès connexion
- ✅ Compteur de réponses non synchronisées
- ✅ Bouton "Synchroniser maintenant"

### Notifications

- 🔔 Rappel après X heures (configuré par étape)
- 🔔 Notification de bienvenue
- 🔔 Notification de félicitations à la fin

## 🔌 API Endpoints

### GET /api/v1/assistant/steps

Récupère toutes les étapes.

**Réponse :**
```json
[
  {
    "id": "uuid",
    "stepCode": "WELCOME",
    "stepOrder": 1,
    "question": "Bienvenue ! Êtes-vous prêt ?",
    "questionAr": "مرحبا! هل أنت مستعد؟",
    "questionEn": "Welcome! Are you ready?",
    "answerType": "YES_NO",
    "answerOptions": null,
    "navigationRules": {"YES": "NEXT_STEP", "NO": "WELCOME"},
    "nextStepCode": "NEXT_STEP",
    "isCritical": false,
    "reminderAfterHours": null
  }
]
```

### POST /api/v1/assistant/sessions/{userId}/start

Démarre ou reprend une session.

**Réponse :**
```json
{
  "id": "session-uuid",
  "userId": "user-uuid",
  "currentStep": { /* ConversationStepDto */ },
  "status": "ACTIVE",
  "startedAt": "2024-01-01T10:00:00Z",
  "lastInteractionAt": "2024-01-01T10:05:00Z",
  "totalAnswers": 5
}
```

### POST /api/v1/assistant/progress/{userId}/answer

Enregistre une réponse.

**Request body :**
```json
{
  "stepId": "step-uuid",
  "answer": "Oui",
  "answeredAt": "2024-01-01T10:05:00Z",
  "isOffline": false,
  "deviceId": "device-123"
}
```

**Réponse :**
```json
{
  "id": "progress-uuid",
  "userId": "user-uuid",
  "stepId": "step-uuid",
  "stepCode": "WELCOME",
  "answer": "Oui",
  "answeredAt": "2024-01-01T10:05:00Z",
  "syncedAt": "2024-01-01T10:05:01Z",
  "isOffline": false
}
```

### POST /api/v1/assistant/progress/{userId}/sync

Synchronise plusieurs réponses offline.

**Request body :**
```json
{
  "answers": [
    {
      "stepId": "step-uuid-1",
      "answer": "Oui",
      "answeredAt": "2024-01-01T10:00:00Z",
      "isOffline": true,
      "deviceId": "device-123"
    },
    {
      "stepId": "step-uuid-2",
      "answer": "Non",
      "answeredAt": "2024-01-01T10:05:00Z",
      "isOffline": true,
      "deviceId": "device-123"
    }
  ],
  "deviceId": "device-123",
  "lastSyncTimestamp": 1704106800000
}
```

## 🎨 Personnalisation

### Modifier les questions

Éditez le fichier `seed_conversation_steps.sql` et modifiez les étapes :

```sql
UPDATE conversation_steps
SET question = 'Votre nouvelle question ?',
    question_ar = 'سؤالك الجديد؟',
    question_en = 'Your new question?'
WHERE step_code = 'WELCOME';
```

### Ajouter de nouvelles étapes

```sql
INSERT INTO conversation_steps (
    step_code, step_order, question, answer_type, next_step_code
) VALUES (
    'MY_NEW_STEP', 25, 'Ma nouvelle question ?', 'YES_NO', 'NEXT_STEP'
);
```

### Modifier les couleurs du chat

Dans `chat_bubble.dart` :

```dart
decoration: BoxDecoration(
  color: message.isBot
      ? Colors.blue[50]  // <- Couleur bot
      : Colors.green,    // <- Couleur utilisateur
)
```

## 🐛 Troubleshooting

### Problème : "No steps found"

**Solution :**
1. Vérifiez que le script SQL a bien été exécuté
2. Vérifiez les logs backend : `SELECT * FROM conversation_steps;`
3. Testez l'API manuellement : `curl http://localhost:8080/api/v1/assistant/steps`

### Problème : "Sync failed"

**Solution :**
1. Vérifiez la connexion réseau
2. Vérifiez l'URL de l'API dans `assistant_provider.dart`
3. Vérifiez les logs de synchronisation : `BotService` logs

### Problème : "Hive error"

**Solution :**
1. Supprimez les données Hive : `Hive.deleteFromDisk()`
2. Régénérez les adapters : `flutter pub run build_runner build --delete-conflicting-outputs`
3. Redémarrez l'app

## 📊 Statistiques et Analytics

Pour tracker l'utilisation :

```dart
final stats = await ref.read(assistantChatProvider.notifier).getStats();

print('Étapes complétées: ${stats['completedSteps']}');
print('Total étapes: ${stats['totalSteps']}');
print('Progression: ${stats['progressPercentage']}%');
print('Réponses non sync: ${stats['unsyncedAnswers']}');
```

## 🔐 Sécurité

### Authentification

Ajouter un intercepteur Dio pour le token JWT :

```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseURL: 'https://api.com'));
  
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(authProvider).getToken();
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    },
  ));
  
  return dio;
});
```

### Validation backend

Le backend valide déjà les entrées avec `@Valid` et `@NotNull`.

## 🎯 Prochaines Évolutions

- [ ] Support vocal (Speech-to-Text)
- [ ] Export PDF de la progression
- [ ] Mode groupe (plusieurs utilisateurs)
- [ ] Gamification (badges, points)
- [ ] Analytics avancés
- [ ] Mode coaching personnalisé

## 📞 Support

Pour toute question ou problème, consultez :
- 📖 README détaillé : `lib/features/assistant/README.md`
- 💬 Logs : Activez le mode verbose dans Logger
- 🐛 Issues : Créez une issue GitHub

---

✨ **Félicitations !** Vous avez maintenant un assistant conversationnel complet et fonctionnel ! 🎉

