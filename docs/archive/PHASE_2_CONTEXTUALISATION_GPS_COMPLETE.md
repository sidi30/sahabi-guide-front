# ✅ Phase 2 : Contextualisation GPS + Temps - TERMINÉE

## 🎯 Objectifs

La Phase 2 visait à rendre le bot intelligent en fonction du **contexte GPS** et du **temps**, offrant une expérience personnalisée basée sur la localisation réelle de l'utilisateur pendant le Hajj.

---

## 📦 Fichiers créés/modifiés

### ✨ Nouveaux fichiers

1. **`ritual_context_model.dart`**  
   - Modèle de données pour le contexte rituel
   - Contient : localisation, duas suggérées, rappels urgents, position GPS, date Hijri
   - Classe `HolyPlace` pour définir les lieux saints avec coordonnées précises

2. **`context_service.dart`**  
   - Service de détection de localisation GPS
   - Détecte automatiquement si l'utilisateur est à :
     - 🕋 Masjid al-Haram (1 km de rayon)
     - 🏕️ Mina (3 km de rayon)
     - ⛰️ Arafat (5 km de rayon)
     - 🌙 Muzdalifah (2 km de rayon)
     - 🏙️ La Mecque (10 km de rayon)
   - Suggère des **duas contextuelles** selon le lieu
   - Génère des **rappels urgents** selon le lieu et l'heure

### 🔧 Fichiers modifiés

3. **`bot_service.dart`**  
   - Intégration du `ContextService`
   - Mise à jour automatique du contexte GPS à chaque étape
   - Adaptation des questions et messages selon le contexte
   - Ajout de duas et rappels urgents contextuels
   - Nouvelles méthodes : `getCurrentContext()`, `refreshContext()`
   - Statistiques enrichies avec infos GPS

4. **`bot_provider.dart`**  
   - Ajout du provider `contextServiceProvider`
   - Injection du `ContextService` dans `BotService`

---

## 🌍 Fonctionnalités ajoutées

### 1. ✅ Détection GPS automatique

Le bot détecte automatiquement la localisation de l'utilisateur et s'adapte :

```dart
📍 Je vois que vous êtes à Arafat !
```

### 2. 🤲 Duas contextuelles suggérées

Le bot affiche automatiquement les duas appropriées selon le lieu :

**Exemple à Arafat :**
```
🤲 DUAS RECOMMANDÉES :
لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ
La ilaha illa Allah wahdahu la sharika lah
رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً
```

**Exemple à Mina :**
```
🤲 DUAS RECOMMANDÉES :
بِسْمِ اللَّهِ اللَّهُ أَكْبَرُ
Bismillah, Allahu Akbar (au Ramy)
```

### 3. ⚠️ Rappels urgents automatiques

Le bot affiche des rappels urgents critiques selon le lieu et l'heure :

**Exemple à Arafat :**
```
⚠️ RAPPELS URGENTS :
⚠️ CRUCIAL : Restez à Arafat jusqu'au coucher du soleil !
🕌 Multipliez les invocations : c'est le meilleur jour de l'année.
💧 Hydratez-vous régulièrement.
⏰ Le coucher du soleil approche. Restez à Arafat !
```

**Exemple à Muzdalifah :**
```
⚠️ RAPPELS URGENTS :
🪨 N'oubliez pas de collecter 49 cailloux (taille pois chiche).
🌙 Passez la nuit ici jusqu'au Fajr au minimum.
```

**Exemple à Mina :**
```
⚠️ RAPPELS URGENTS :
🎯 Lapidez les Jamarat après le Dhuhr.
⛺ Restez à Mina pour les nuits des jours de Tashriq.
```

### 4. 🗺️ Coordonnées GPS précises des lieux saints

```dart
Masjid al-Haram : 21.4225°N, 39.8262°E (rayon 1 km)
Mina            : 21.4203°N, 39.8875°E (rayon 3 km)
Arafat          : 21.3551°N, 39.9843°E (rayon 5 km)
Muzdalifah      : 21.3892°N, 39.9198°E (rayon 2 km)
La Mecque       : 21.3891°N, 39.8579°E (rayon 10 km)
```

### 5. 📅 Détection de la date Hijri (approximative)

Le bot calcule une approximation de la date Hijri pour contextualiser les rituels.

---

## 🔧 Architecture technique

### Flux de données

```
┌─────────────────┐
│  BotChatPage    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  BotProvider    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐       ┌──────────────────┐
│   BotService    │◄──────│ ContextService   │
└────────┬────────┘       └────────┬─────────┘
         │                         │
         │                         ▼
         │                  ┌──────────────┐
         │                  │  Geolocator  │
         │                  │  (GPS Native)│
         │                  └──────────────┘
         ▼
┌─────────────────┐
│ KnowledgeBase   │
│    Service      │
└─────────────────┘
```

### Logique de contextualisation

```dart
// 1. Récupération du contexte GPS
_lastContext = await contextService.getCurrentContext();

// 2. Détection du lieu actuel
final currentPlace = _detectCurrentPlace(position);

// 3. Détermination du rituel actuel
final currentRitual = _determineCurrentRitual(currentPlace, DateTime.now());

// 4. Récupération des duas suggérées
final suggestedDuas = _getSuggestedDuas(currentPlace, currentRitual);

// 5. Récupération des rappels urgents
final urgentReminders = _getUrgentReminders(currentPlace, currentRitual, DateTime.now());
```

---

## 📱 Gestion des permissions GPS

Le `ContextService` gère automatiquement les permissions :

1. ✅ Vérifie si le GPS est activé
2. ✅ Demande la permission si nécessaire
3. ✅ Gère les refus gracieusement (pas d'erreur bloquante)
4. ✅ Fonctionne en mode dégradé si pas de GPS

```dart
Future<bool> _checkLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission != LocationPermission.deniedForever;
}
```

---

## 🧪 Comment tester

### Option 1 : Simulation GPS (Émulateur Android)

1. Ouvrez l'émulateur Android
2. Allez dans `Extended Controls` (⋯) > `Location`
3. Entrez les coordonnées d'Arafat :
   - Latitude : `21.3551`
   - Longitude : `39.9843`
4. Cliquez sur `Send`
5. Lancez l'application et démarrez le bot

### Option 2 : Simulation GPS (Émulateur iOS)

1. Ouvrez le simulateur iOS
2. Menu `Features` > `Location` > `Custom Location...`
3. Entrez les coordonnées d'Arafat
4. Lancez l'application et démarrez le bot

### Option 3 : Test manuel sur device réel

Utilisez une application de simulation GPS (nécessite parfois root/jailbreak) :
- **Android** : Fake GPS Location (par Lexa)
- **iOS** : iTools Virtual Location

### Coordonnées de test

```dart
// Arafat (jour le plus important)
Lat: 21.3551, Lon: 39.9843

// Mina (lapidation)
Lat: 21.4203, Lon: 39.8875

// Muzdalifah (nuit sous les étoiles)
Lat: 21.3892, Lon: 39.9198

// Masjid al-Haram (Tawaf)
Lat: 21.4225, Lon: 39.8262

// Hors zone (pour tester mode normal)
Lat: 48.8566, Lon: 2.3522 (Paris)
```

---

## 📊 Statistiques enrichies

Le bot expose maintenant des stats GPS :

```dart
final stats = botService.getStats();
// {
//   'current_step': 'Arafat',
//   'current_location': 'Arafat',
//   'is_in_holy_place': true,
//   'suggested_duas_count': 3,
//   'urgent_reminders_count': 4,
//   'progress_percentage': 64,
//   ...
// }
```

---

## 🚀 Prochaines étapes (Phase 3)

- 🔔 **Notifications locales automatiques** basées sur GPS et heure
- 🌐 **Intégration LLM optionnelle** (HuggingFace, OpenAI)
- 💾 **Persistance de l'historique** (Hive)
- 🎨 **Affichage carte interactive** avec position en temps réel
- 🌙 **Intégration calendrier Hijri précis** (librairie dédiée)

---

## ✅ Résumé Phase 2

| Fonctionnalité | Status |
|---|---|
| Détection GPS automatique | ✅ |
| Détection lieux saints (5 lieux) | ✅ |
| Duas contextuelles | ✅ |
| Rappels urgents automatiques | ✅ |
| Date Hijri approximative | ✅ |
| Gestion permissions GPS | ✅ |
| Mode dégradé sans GPS | ✅ |
| Intégration dans BotService | ✅ |
| Statistiques enrichies | ✅ |

---

**🎉 Phase 2 terminée avec succès !**

*Pour toute question ou amélioration, consultez la documentation dans `NOUVEAU_BOT_HAJJ_README.md`.*

