# 🕋 Plan Complet : Finalisation Bot Hajj Interactif

## 📊 Vue d'Ensemble du Projet

**Objectif** : Créer un assistant numérique complet pour guider les pèlerins pendant le Hajj, étape par étape, avec une interface intuitive et des interactions riches.

---

## ✅ État Actuel (Acquis)

### Backend Spring Boot
- ✅ 3 tables créées : `conversation_steps`, `user_conversation_progress`, `conversation_sessions`
- ✅ 5 endpoints REST fonctionnels :
  - `GET /api/v1/assistant/steps` - Liste des étapes
  - `POST /api/v1/assistant/sessions/{userId}/start` - Démarrer/reprendre session
  - `POST /api/v1/assistant/progress/{userId}/answer` - Sauvegarder réponse
  - `POST /api/v1/assistant/progress/{userId}/sync` - Synchronisation offline
  - `GET /api/v1/assistant/progress/{userId}` - Récupérer progression
- ✅ 28 étapes seedées (24 principales + 4 supplémentaires)
- ✅ Support JSONB pour navigation dynamique

### Frontend Flutter
- ✅ Architecture modulaire (data/domain/presentation)
- ✅ 31 fichiers créés :
  - Models (Hive + JSON)
  - Services (bot, sync, notifications)
  - Datasources (remote + local)
  - UI (chat page, bubbles, quick replies, typing indicator)
  - Providers (Riverpod)
- ✅ Cache local avec Hive
- ✅ Interface chat fonctionnelle
- ✅ Intégration au menu principal

### Problèmes Résolus Récemment
- ✅ Correction `baseURL` → `baseUrl` (Dio 5.x)
- ✅ UUID utilisateur valide (Ahmed Ben Ali)
- ✅ Enum `AnswerType` corrigé (NONE → TEXT)
- ⏳ Navigation : Script SQL corrigé créé (`SEED_ASSISTANT_FIXED.sql`)

---

## 🎯 Plan d'Implémentation : 3 Phases

### 📍 **Phase 1 : Stabilisation & UX de Base** (1-2 jours)

#### 1.1. Corriger la Navigation ⚠️ URGENT
- [x] Créer `SEED_ASSISTANT_FIXED.sql` avec clés en majuscules
- [ ] Exécuter le script SQL
- [ ] Tester la navigation Oui/Non
- [ ] Vérifier toutes les étapes s'enchaînent correctement

#### 1.2. Bouton Flottant Animé 🎨
**Objectif** : Rendre le bot accessible partout

**Implémentation** :
```dart
// Créer : lib/features/assistant/presentation/widgets/floating_assistant_button.dart
class FloatingAssistantButton extends StatefulWidget {
  // Bouton flottant avec animation de rotation
  // Icône Kaaba ou croissant
  // Halo lumineux (AnimatedContainer)
  // Ouvre le chat en modal
}
```

**Placement** :
- Ajouter dans `main_shell.dart` pour qu'il soit visible partout
- Position : Bottom-right avec offset (16, 80)
- Z-index au-dessus de la navigation

**Animation** :
- Rotation lente continue (6s par tour)
- Effet "respiration" (scale 1.0 → 1.1 → 1.0)
- Shadow animé

#### 1.3. Gestion d'Erreurs Renforcée 🛡️
**Fichiers à améliorer** :
- `bot_service.dart` :
  - Ajouter try-catch autour de chaque appel API
  - Vérifier tous les `null` avant utilisation
  - Ajouter des logs détaillés
  
- `assistant_provider.dart` :
  - Gérer les états d'erreur dans `AsyncValue`
  - Afficher des messages d'erreur user-friendly
  
- `assistant_chat_page.dart` :
  - Widget `_buildErrorState` amélioré avec retry
  - Snackbar pour erreurs non-critiques

#### 1.4. Mode Offline Amélioré 📴
**Objectif** : UX fluide même sans connexion

**Features** :
- Indicateur de statut connexion (chip en haut)
- Reconnexion automatique toutes les 30s
- Sync automatique quand retour online
- Badge "Non synchronisé" sur les réponses offline

**Implémentation** :
```dart
// Ajouter dans assistant_chat_page.dart
Widget _buildConnectivityIndicator() {
  // Chip avec icône wifi + texte "En ligne" / "Hors ligne"
  // Couleur verte/grise selon statut
}
```

#### 1.5. Indicateur de Progression 📊
**Objectif** : Montrer au pèlerin où il en est

**Implémentation** :
- Barre de progression en haut du chat : `X / 28 étapes complétées (Y%)`
- Mini-graphique circulaire dans l'AppBar
- Animation quand une étape est complétée

```dart
LinearProgressIndicator(
  value: completedSteps / totalSteps,
  backgroundColor: Colors.grey[300],
  color: Colors.green,
)
```

---

### 📍 **Phase 2 : Enrichissement du Contenu Hajj** (3-5 jours)

#### 2.1. Contenu Réel des Étapes du Hajj 🕋

**Objectif** : Remplacer les étapes de test par le vrai contenu du Hajj

**Étapes Complètes à Créer** :

1. **Préparation avant départ** (3 étapes)
   - Préparation spirituelle
   - Documents et santé
   - Bagages et recommandations

2. **Ihram** (4 étapes)
   - Qu'est-ce que l'Ihram ?
   - Où et comment le porter ?
   - Interdictions en Ihram
   - Intention (Niyyah) et Talbiya

3. **Arrivée à la Mecque** (2 étapes)
   - Premier Tawaf (Tawaf al-Qudum)
   - Prière derrière Maqam Ibrahim

4. **Sa'i** (3 étapes)
   - Explication du Sa'i
   - Comment effectuer le Sa'i
   - Invocations pendant le Sa'i

5. **Mina** (2 étapes)
   - 8 Dhul Hijjah : arrivée à Mina
   - Prières et préparation pour Arafat

6. **Arafat** (4 étapes) ⭐ JOUR CRUCIAL
   - 9 Dhul Hijjah : importance
   - Station sur Arafat (midi-coucher du soleil)
   - Invocations d'Arafat
   - Départ vers Muzdalifah

7. **Muzdalifah** (2 étapes)
   - Nuit à Muzdalifah
   - Ramassage des cailloux

8. **Rami al-Jamarat** (3 étapes)
   - Premier jour : Grande Jamarat uniquement
   - Jours suivants : les 3 Jamarat
   - Comment lancer correctement

9. **Sacrifice (Qurban)** (2 étapes)
   - Obligation du sacrifice
   - Options et procédure

10. **Rasage/Coupe** (1 étape)
    - Halq (rasage) ou Taqsir (coupe)

11. **Tawaf al-Ifadah** (2 étapes)
    - Moment et importance
    - Exécution

12. **Jours de Tashriq** (2 étapes)
    - 11-13 Dhul Hijjah à Mina
    - Rami quotidien

13. **Tawaf al-Wada** (1 étape)
    - Dernier Tawaf avant départ

**SQL à Créer** : `seed_hajj_complete_steps.sql` (50+ étapes détaillées)

#### 2.2. Types d'Interactions Variées 🎮

**Objectif** : Dépasser le simple Oui/Non

**Types d'interactions à implémenter** :

1. **QCM à 3-4 choix** (déjà supporté par `MULTIPLE_CHOICE`)
   ```json
   {
     "answerType": "MULTIPLE_CHOICE",
     "answerOptions": [
       "J'ai terminé ✅",
       "Je suis en chemin 🚶",
       "J'ai besoin d'aide ❓",
       "Je ne sais pas 🤔"
     ]
   }
   ```

2. **Sélection d'heure** (nouveau type)
   ```dart
   // Ajouter AnswerType.TIME
   // Widget TimePicker pour "À quelle heure es-tu arrivé à Mina ?"
   ```

3. **Sélection de date** (déjà dans enum)
   ```dart
   // Utiliser AnswerType.DATE
   // DatePicker pour "Quelle est ta date de départ ?"
   ```

4. **Slider** (nouveau type)
   ```dart
   // Pour "Sur une échelle de 1 à 10, comment te sens-tu ?"
   // AnswerType.SCALE
   ```

5. **Images à choix** (nouveau type)
   ```dart
   // Pour "Sélectionne l'image qui correspond à ta situation"
   // AnswerType.IMAGE_CHOICE
   ```

#### 2.3. Intégration Audio 🔊

**Objectif** : Lecture automatique des questions et douas

**Implémentation** :

1. **Backend** : Ajouter champ `audioUrl` à `ConversationStep`
   ```java
   @Column(name = "audio_url")
   private String audioUrl; // URL vers Firebase Storage ou S3
   ```

2. **Frontend** : Intégrer `audioplayers`
   ```dart
   // Créer : lib/features/assistant/presentation/widgets/audio_player_widget.dart
   class AudioPlayerWidget extends StatefulWidget {
     final String? audioUrl;
     // Bouton play/pause
     // Barre de progression
     // Vitesse de lecture (0.5x, 1x, 1.5x, 2x)
   }
   ```

3. **Auto-play** : Option dans settings
   ```dart
   // Si enabled, joue automatiquement l'audio de chaque étape
   final autoPlayAudio = ref.watch(settingsProvider).autoPlayAudio;
   ```

#### 2.4. Médias Riches 📸🎥

**Objectif** : Ajouter images et vidéos explicatives

**Backend** :
```java
@Column(name = "image_url")
private String imageUrl; // Image illustrative (ex: photo Kaaba)

@Column(name = "video_url")
private String videoUrl; // Vidéo tutoriel (ex: comment faire le Tawaf)
```

**Frontend** :
```dart
// Afficher les images dans les messages du bot
if (step.imageUrl != null) {
  Image.network(step.imageUrl)
}

// Intégrer video_player pour les vidéos
if (step.videoUrl != null) {
  VideoPlayerWidget(url: step.videoUrl)
}
```

---

### 📍 **Phase 3 : Features Avancées** (5-7 jours)

#### 3.1. Notifications Locales 🔔

**Objectif** : Rappels intelligents basés sur la progression

**Implémentation** :

1. **Notifications programmées** :
   ```dart
   // Déjà intégré : assistant_notification_service.dart
   // À améliorer :
   - Notification 2h avant une étape critique (Arafat, Mina)
   - Rappel quotidien si inactivité > 24h
   - Notification de félicitations après chaque étape
   ```

2. **Géolocalisation** (bonus) :
   ```dart
   // Si pèlerin entre dans une zone (geofencing)
   // Déclencher notification : "Tu es arrivé à Mina, veux-tu marquer cette étape ?"
   ```

#### 3.2. Mode Vocal 🎙️

**Objectif** : Pour pèlerins analphabètes ou malvoyants

**Implémentation** :

1. **Text-to-Speech** :
   ```dart
   // Package : flutter_tts
   final flutterTts = FlutterTts();
   
   await flutterTts.setLanguage("fr-FR");
   await flutterTts.speak(questionText);
   ```

2. **Speech-to-Text** (bonus avancé) :
   ```dart
   // Package : speech_to_text
   // Permettre de répondre vocalement
   ```

3. **UI adaptée** :
   - Bouton micro géant pour activer
   - Feedback visuel (onde sonore animée)
   - Mode "Écoute" avec grandes icônes

#### 3.3. Multilingue 🌍

**Objectif** : Support FR / EN / AR

**Backend** :
- Déjà présent : `question`, `questionEn`, `questionAr` dans `ConversationStep`

**Frontend** :
```dart
// Dans bot_service.dart
String getLocalizedQuestion(ConversationStepModel step) {
  final locale = ref.watch(languageProvider).locale;
  switch (locale) {
    case 'ar':
      return step.questionAr ?? step.question;
    case 'en':
      return step.questionEn ?? step.question;
    default:
      return step.question;
  }
}
```

**UI** :
- Sélecteur de langue dans settings
- Switch automatique selon langue du device

#### 3.4. Analytics & Insights 📈

**Objectif** : Suivre l'utilisation et améliorer

**Features** :
- Temps passé sur chaque étape
- Taux de complétion
- Questions les plus difficiles (où les pèlerins restent bloqués)
- Feedback utilisateur (notation à la fin)

**Backend** :
```java
@Entity
public class BotAnalytics {
    private UUID userId;
    private String stepCode;
    private Integer timeSpentSeconds;
    private Integer helpRequestedCount;
    private Integer retryCount;
    private LocalDateTime timestamp;
}
```

#### 3.5. Mode Groupe 👥

**Objectif** : Partager la progression avec d'autres pèlerins

**Features** :
- Créer un groupe familial
- Voir la progression de chaque membre
- Notifications "Ahmed a terminé le Tawaf"
- Chat de groupe intégré (bonus)

---

## 🛠️ Architecture Technique Complète

### Backend (Spring Boot)

```
assistant/
├── domain/
│   ├── ConversationStep.java (amélioré avec audio, video, images)
│   ├── UserConversationProgress.java
│   ├── ConversationSession.java
│   └── BotAnalytics.java (nouveau)
├── app/
│   ├── AssistantService.java
│   ├── AudioService.java (nouveau - génération audio si pas fourni)
│   └── AnalyticsService.java (nouveau)
├── api/
│   ├── AssistantController.java
│   ├── AnalyticsController.java (nouveau)
│   └── dto/...
└── infra/
    └── repositories/...
```

### Frontend (Flutter)

```
assistant/
├── domain/
│   ├── entities/ (models métier)
│   └── repositories/ (interfaces)
├── data/
│   ├── models/ (DTOs + Hive)
│   ├── datasources/
│   ├── repositories/ (implémentations)
│   └── services/
│       ├── bot_service.dart
│       ├── audio_service.dart (nouveau)
│       ├── tts_service.dart (nouveau)
│       ├── sync_service.dart
│       └── notification_service.dart
├── presentation/
│   ├── pages/
│   │   ├── assistant_chat_page.dart
│   │   └── assistant_stats_page.dart (nouveau)
│   ├── widgets/
│   │   ├── chat_bubble.dart
│   │   ├── quick_reply_buttons.dart
│   │   ├── typing_indicator.dart
│   │   ├── floating_assistant_button.dart (nouveau)
│   │   ├── audio_player_widget.dart (nouveau)
│   │   ├── video_player_widget.dart (nouveau)
│   │   ├── progress_indicator_widget.dart (nouveau)
│   │   └── time_picker_widget.dart (nouveau)
│   └── providers/
│       └── assistant_provider.dart
└── assistant_initializer.dart
```

---

## 📋 Checklist de Validation

### Stabilité ✅
- [ ] Aucun crash pendant 30 min d'utilisation continue
- [ ] Toutes les transitions sont fluides
- [ ] Mode offline fonctionne parfaitement
- [ ] Reconnexion automatique testée
- [ ] Logs d'erreurs complets et exploitables

### UX/UI ✅
- [ ] Bouton flottant accessible et visible
- [ ] Animations non-intrusives
- [ ] Temps de réponse < 300ms
- [ ] Indicateur de chargement toujours visible
- [ ] Messages d'erreur clairs et actionnables

### Fonctionnalités ✅
- [ ] Toutes les 50+ étapes du Hajj implémentées
- [ ] Navigation logique testée de bout en bout
- [ ] QCM variés fonctionnels
- [ ] Audio se lit correctement
- [ ] Progression sauvegardée et récupérable
- [ ] Notifications programmées testées

### Performance ✅
- [ ] Taille de l'app < 50 MB
- [ ] Consommation RAM < 150 MB
- [ ] Batterie : consommation normale
- [ ] Cache local optimisé (< 10 MB)
- [ ] Sync en arrière-plan efficace

### Compatibilité ✅
- [ ] Android 8+ (API 26+)
- [ ] iOS 12+
- [ ] Mode Web (bonus)
- [ ] Tablettes (layout adaptatif)
- [ ] RTL pour l'arabe

---

## 🚀 Prochaines Étapes Immédiates

### Aujourd'hui (Priorité Max)
1. ✅ Exécuter `SEED_ASSISTANT_FIXED.sql`
2. ✅ Tester navigation corrigée
3. 🔄 Créer `floating_assistant_button.dart`
4. 🔄 Intégrer le bouton dans `main_shell.dart`
5. 🔄 Ajouter indicateur de progression

### Cette Semaine
1. Renforcer gestion d'erreurs
2. Améliorer mode offline
3. Créer contenu réel des 50 étapes Hajj
4. Intégrer audio de base

### Semaine Prochaine
1. Implémenter types d'interactions variés
2. Ajouter images/vidéos
3. Notifications locales
4. Tests utilisateurs beta

---

## 📚 Ressources Nécessaires

### Packages Flutter à Ajouter
```yaml
dependencies:
  # Déjà installés :
  # - hive, flutter_riverpod, dio, connectivity_plus, flutter_local_notifications
  
  # À ajouter :
  audioplayers: ^5.2.1  # Lecture audio
  video_player: ^2.8.1  # Lecture vidéo
  flutter_tts: ^4.0.2   # Text-to-Speech
  speech_to_text: ^6.6.0  # Speech-to-Text (bonus)
  geolocator: ^10.1.0  # Géolocalisation (bonus)
  flutter_animate: ^4.3.0  # Animations avancées
  lottie: ^3.0.0  # Animations Lottie (bouton flottant)
```

### Contenus à Préparer
- [ ] 50+ textes d'étapes du Hajj (FR/EN/AR)
- [ ] 30+ fichiers audio (invocations, explications)
- [ ] 20+ images (Kaaba, Mina, Arafat, etc.)
- [ ] 10+ vidéos courtes (tutoriels)
- [ ] Icônes personnalisées (Kaaba, croissant)

---

## 🎯 Objectif Final

**Un assistant numérique complet, fluide et professionnel** qui :
- Guide réellement les pèlerins pendant leur Hajj
- Est utilisable par tous (lettrés, analphabètes, multilingue)
- Fonctionne offline pendant tout le voyage
- Donne confiance et sérénité aux pèlerins

**Impact attendu** : Réduire le stress des pèlerins, les aider à accomplir tous les rituels correctement, et rendre leur Hajj plus spirituel et serein. 🕋✨

---

*Plan créé le 23 Octobre 2025*  
*Projet : Sahabi Guide - Bot Hajj Interactif*

