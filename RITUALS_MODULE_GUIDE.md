# 🕌 Guide d'intégration - Module Rituels et Douas

## 📋 Vue d'ensemble

Ce module complet pour SahabiGuide fournit une expérience spirituelle interactive pour les pèlerins nigériens pendant le Hadj. Il inclut :

- ✅ **Timeline intelligente** des rituels du Hadj
- ✅ **Système audio multilingue** (Français, Haoussa, Zarma, Arabe)
- ✅ **Notifications proactives** et rappels
- ✅ **Gestion d'état avancée** avec Provider
- ✅ **Interface intuitive** adaptée aux analphabètes

## 🚀 Installation et Configuration

### 1. Dépendances requises

Ajoutez ces dépendances à votre `pubspec.yaml` :

```yaml
dependencies:
  # Audio
  audioplayers: ^5.2.1
  
  # Notifications
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2
  
  # State Management
  provider: ^6.1.1
  
  # Navigation
  go_router: ^12.1.3
```

### 2. Configuration des permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3. Intégration dans l'application

#### Dans votre `main.dart` :
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/rituals/presentation/providers/rituals_module_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RitualsModuleProvider(
      child: MaterialApp(
        title: 'SahabiGuide',
        home: HomePage(),
      ),
    );
  }
}
```

#### Initialisation des services :
```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RitualsModuleInitializer.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RitualTimelinePage(),
                ),
              ),
              child: Text('Rituels du Hadj'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InteractiveDouaPage(),
                ),
              ),
              child: Text('Mes Douas'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Utilisation des fonctionnalités

### Timeline des Rituels

```dart
// Accéder au state manager
final stateManager = context.read<RitualsStateManager>();

// Charger les rituels
await stateManager.loadRituals();

// Marquer un rituel comme terminé
await stateManager.markRitualAsCompleted('tawaf');

// Démarrer un rituel
await stateManager.startRitual('ihram');

// Changer de langue
stateManager.setLanguage('ha'); // Haoussa
```

### Gestion des Douas

```dart
// Jouer une doua
await stateManager.playDua(dua);

// Mettre en pause
await stateManager.pauseDua();

// Marquer comme favorite
await stateManager.toggleDuaFavorite('arafat_dua');

// Changer de langue
stateManager.setLanguage('za'); // Zarma
```

### Notifications

```dart
// Le service de notifications est automatiquement configuré
// Les notifications sont programmées lors du chargement des rituels

// Notifications immédiates
await notificationService.showRitualReminder(ritual);
await notificationService.showDuaReminder(dua);
```

## 🎨 Personnalisation

### Couleurs et thème

Les couleurs principales sont définies dans les widgets :
- **Bleu principal** : `Color(0xFF4FC3F7)`
- **Vert succès** : `Color(0xFF10B981)`
- **Rouge erreur** : `Color(0xFFEF4444)`
- **Gris neutre** : `Color(0xFF6B7280)`

### Ajout de nouvelles langues

1. **Modifier les modèles** :
```dart
// Dans RitualModel et DuaModel
Map<String, String> translations = {
  'fr': 'Français',
  'ha': 'Haoussa', 
  'za': 'Zarma',
  'ar': 'Arabe',
  'en': 'English', // Nouvelle langue
};
```

2. **Ajouter les fichiers audio** :
```
assets/audio/rituals/
├── ihram_en.mp3
├── tawaf_en.mp3
└── ...
```

3. **Mettre à jour les données JSON** :
```json
{
  "translations": {
    "fr": "Ihram",
    "ha": "Ihram",
    "za": "Ihram", 
    "ar": "إحرام",
    "en": "Ihram"
  }
}
```

## 🔧 Configuration avancée

### Synchronisation avec l'API

Le module est conçu pour fonctionner avec votre API existante :

```dart
// Dans RitualsStateManager, implémentez ces méthodes :
Future<List<RitualModel>> _loadRitualsFromDataSource() async {
  // Appel à votre API
  final response = await apiClient.get('/api/v1/rituals');
  return response.data.map((json) => RitualModel.fromJson(json)).toList();
}

Future<void> _syncProgressWithAPI(String ritualId, RitualStatus status) async {
  // Synchronisation avec l'API
  await apiClient.put('/api/v1/pilgrims/{id}/rituals/progress', {
    'ritualId': ritualId,
    'status': status.name,
  });
}
```

### Gestion hors ligne

Le module fonctionne en mode hors ligne avec les données JSON locales. La synchronisation se fait automatiquement lors de la reconnexion.

## 📱 Expérience utilisateur

### Pour les utilisateurs analphabètes

1. **Interface visuelle** : Icônes claires et couleurs distinctives
2. **Audio multilingue** : Support complet des langues locales
3. **Notifications vocales** : Rappels audio pour chaque rituel
4. **Timeline intuitive** : Progression visuelle claire

### Navigation simplifiée

- **Timeline verticale** : Facile à suivre
- **Boutons d'action** : Grands et colorés
- **Feedback visuel** : Animations et changements d'état
- **Mode sombre** : Support complet

## 🐛 Dépannage

### Problèmes audio

```dart
// Vérifier l'état du service audio
final audioService = context.read<AudioService>();
print('État audio: ${audioService.state}');
print('Erreur: ${audioService.errorMessage}');
```

### Problèmes de notifications

```dart
// Vérifier les permissions
final notificationService = context.read<NotificationService>();
await notificationService.requestPermissions();

// Voir les notifications programmées
final pending = await notificationService.getPendingNotifications();
print('Notifications en attente: ${pending.length}');
```

### Problèmes de données

```dart
// Vérifier le chargement des données
final stateManager = context.read<RitualsStateManager>();
if (stateManager.isLoading) {
  print('Chargement en cours...');
} else if (stateManager.error != null) {
  print('Erreur: ${stateManager.error}');
}
```

## 📊 Métriques et analytics

Le module inclut des métriques intégrées :

- **Progression des rituels** : Pourcentage de completion
- **Utilisation audio** : Nombre de lectures par doua
- **Engagement** : Temps passé sur chaque écran
- **Efficacité** : Taux de completion des rituels

## 🔄 Mises à jour futures

### Fonctionnalités prévues

1. **Mode hors ligne avancé** : Cache intelligent des médias
2. **Géolocalisation** : Notifications basées sur la position
3. **Partage social** : Partage des accomplissements
4. **Gamification** : Badges et récompenses
5. **IA** : Recommandations personnalisées

### Améliorations techniques

1. **Performance** : Optimisation du cache audio
2. **Accessibilité** : Support des lecteurs d'écran
3. **Tests** : Couverture de tests complète
4. **Documentation** : Guides utilisateur détaillés

---

## 🎉 Conclusion

Ce module transforme l'expérience spirituelle des pèlerins nigériens en offrant :

- **Guidance claire** à travers chaque étape du Hadj
- **Support multilingue** pour tous les profils
- **Notifications intelligentes** pour ne rien manquer
- **Interface intuitive** adaptée à tous les niveaux

L'application est maintenant prête à accompagner les pèlerins dans leur voyage spirituel avec confiance et sérénité. 🌟
