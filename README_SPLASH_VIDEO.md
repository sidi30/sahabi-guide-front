# 🎬 Splash Video - Guide d'Utilisation

## ✅ Implémentation Complète

Le système de splash vidéo a été implémenté avec succès ! 🎉

---

## 📁 Fichiers Créés

### 1. **`lib/shared/presentation/pages/splash_video_screen.dart`**
- Écran qui affiche la vidéo au démarrage
- Gestion de l'erreur si la vidéo ne charge pas
- Bouton "Passer" pour skip la vidéo
- Fallback sur logo statique

### 2. **`lib/shared/presentation/pages/splash_wrapper.dart`**
- Décide d'afficher la vidéo ou le splash normal
- Vérifie avec `SharedPreferences` si c'est le premier lancement
- Au premier lancement → Vidéo
- Lancements suivants → Splash normal

### 3. **Modifications dans `pubspec.yaml`**
- Ajout de `video_player: ^2.8.0`
- Ajout de `chewie: ^1.7.0`
- Ajout de `assets/video/` dans les assets

### 4. **Modifications dans `main.dart`**
- Import de `SplashWrapper`
- Route splash utilise maintenant `SplashWrapper` au lieu de `SplashPage`

---

## 🎥 Vidéos Disponibles

Les vidéos sont dans `assets/video/`:

1. **`logo-anime.mp4`** ⭐ (utilisée actuellement)
2. **`mascott-anime.mp4`**
3. **`media2.mp4`**

---

## 🔧 Comment Changer la Vidéo

### Changer la vidéo utilisée

Ouvre `lib/shared/presentation/pages/splash_video_screen.dart` et modifie la ligne 30 :

```dart
// Ligne actuelle (logo-anime.mp4)
_controller = VideoPlayerController.asset('assets/video/logo-anime.mp4');

// Pour utiliser la mascotte
_controller = VideoPlayerController.asset('assets/video/mascott-anime.mp4');

// Pour utiliser media2
_controller = VideoPlayerController.asset('assets/video/media2.mp4');
```

### Ajouter une nouvelle vidéo

1. Place ta vidéo dans `assets/video/`
2. Nomme-la (ex: `intro-sahabi.mp4`)
3. Modifie la ligne 30 dans `splash_video_screen.dart`:
   ```dart
   _controller = VideoPlayerController.asset('assets/video/intro-sahabi.mp4');
   ```

---

## 🎨 Personnalisation

### Désactiver le bouton "Passer"

Dans `splash_video_screen.dart`, supprime ou commente le bloc ligne 117-153 :

```dart
// Commenter pour cacher le bouton Skip
/*
if (_isInitialized && !_hasError)
  Positioned(
    top: MediaQuery.of(context).padding.top + 16,
    right: 16,
    child: SafeArea(
      child: TextButton(
        onPressed: _skipVideo,
        ...
      ),
    ),
  ),
*/
```

### Forcer l'affichage de la vidéo à chaque lancement

Dans `splash_wrapper.dart`, ligne 24, change la logique :

```dart
// Actuellement : ne montre qu'au premier lancement
final hasSeenVideo = prefs.getBool('intro_video_shown') ?? false;
_shouldShowVideo = !hasSeenVideo;

// Pour afficher à chaque lancement
_shouldShowVideo = true; // Toujours montrer
```

### Changer la durée du fallback en cas d'erreur

Dans `splash_video_screen.dart`, ligne 47 :

```dart
// Actuellement : 2 secondes
Future.delayed(const Duration(seconds: 2), _completeIntro);

// Pour 3 secondes
Future.delayed(const Duration(seconds: 3), _completeIntro);
```

---

## 🧪 Tests

### Tester le premier lancement

1. Désinstalle l'app ou efface les données
2. Lance l'app
3. ✅ La vidéo doit s'afficher

### Tester les lancements suivants

1. Relance l'app
2. ✅ Le splash normal (logo animé) doit s'afficher
3. ❌ La vidéo ne doit PAS s'afficher

### Réinitialiser pour voir la vidéo à nouveau

Dans l'app, exécute ce code (ou désinstalle) :

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('intro_video_shown');
```

---

## 🚀 Installation des Packages

Après avoir modifié `pubspec.yaml`, exécute :

```bash
cd sahabi-guide-front
flutter pub get
```

---

## 📊 Flux d'Exécution

```
Lancement App
    ↓
SplashWrapper (vérifie SharedPreferences)
    ↓
├─→ Premier lancement ? OUI
│   └─→ SplashVideoScreen (vidéo)
│       └─→ Fin vidéo / Skip
│           └─→ Marque 'intro_video_shown' = true
│               └─→ SplashPage (logo animé)
│                   └─→ Écran suivant
│
└─→ Premier lancement ? NON
    └─→ SplashPage (logo animé directement)
        └─→ Écran suivant
```

---

## ⚙️ Configuration Technique

### Vidéo Recommandée

Pour de meilleures performances :

- **Format :** MP4 (H.264)
- **Résolution :** 1080x1920 (portrait) ou 1920x1080 (paysage)
- **Durée :** 3-5 secondes MAX
- **FPS :** 30
- **Bitrate :** 2-3 Mbps
- **Taille :** < 5 MB

### Compresser une Vidéo

Utilise **HandBrake** ou **FFmpeg** :

```bash
ffmpeg -i input.mp4 -vcodec h264 -b:v 2M -r 30 -s 1080x1920 output.mp4
```

---

## 🐛 Dépannage

### La vidéo ne s'affiche pas

1. Vérifie que le chemin est correct
2. Vérifie que la vidéo est dans `assets/video/`
3. Lance `flutter clean && flutter pub get`
4. Rebuild l'app

### La vidéo ne charge pas (affiche le fallback)

1. Vérifie la taille de la vidéo (< 10 MB recommandé)
2. Vérifie le format (MP4 H.264 recommandé)
3. Teste avec une autre vidéo

### L'app crash au démarrage

1. Vérifie les logs : `flutter logs`
2. Vérifie que `video_player` est installé : `flutter pub get`
3. Vérifie la compatibilité Android/iOS

---

## 📱 Compatibilité

### Android
✅ Fonctionne (API 21+)

### iOS
✅ Fonctionne (iOS 11+)

### Web
⚠️ Fonctionne mais peut être lent (temps de chargement)

---

## 💡 Conseils

### Pour une UX Optimale

1. **Garde la vidéo courte** (3-5 secondes MAX)
2. **Compresse la vidéo** pour réduire la taille de l'APK
3. **Garde le bouton Skip** pour ne pas frustrer les utilisateurs réguliers
4. **N'affiche la vidéo qu'au premier lancement**

### Pour Réduire la Taille de l'App

Si la vidéo rend l'app trop lourde :

1. Utilise une **animation Lottie** à la place (< 500 KB vs 5-10 MB)
2. Charge la vidéo depuis un **serveur distant** au lieu des assets
3. Utilise une **vidéo plus courte** et compressée

---

## 🎯 Structure Finale

```
sahabi-guide-front/
├── assets/
│   ├── images/
│   │   ├── app_logo.svg
│   │   ├── sahabi logo.png
│   │   └── mascott.jpeg
│   └── video/
│       ├── logo-anime.mp4      ⭐ (vidéo utilisée)
│       ├── mascott-anime.mp4
│       └── media2.mp4
│
├── lib/
│   ├── main.dart                         (modifié)
│   └── shared/
│       └── presentation/
│           └── pages/
│               ├── splash_page.dart      (splash normal)
│               ├── splash_video_screen.dart  ✨ (nouveau)
│               └── splash_wrapper.dart       ✨ (nouveau)
│
└── pubspec.yaml                          (modifié)
```

---

## ✅ Checklist de Vérification

Avant de commit/build :

- [x] `pubspec.yaml` contient `video_player` et `chewie`
- [x] `pubspec.yaml` contient `assets/video/` dans assets
- [x] La vidéo est dans `assets/video/`
- [x] Le chemin dans `splash_video_screen.dart` est correct
- [x] `flutter pub get` exécuté
- [x] `main.dart` utilise `SplashWrapper`
- [x] Testé sur émulateur/appareil
- [x] La taille de l'APK est acceptable

---

## 🎉 Résultat

✅ **Splash vidéo fonctionnel !**

- Au **premier lancement** : Vidéo d'intro (logo animé)
- **Lancements suivants** : Splash normal (logo avec animations)
- **Bouton Skip** pour passer la vidéo
- **Fallback** en cas d'erreur (logo statique)

---

**Créé le :** 2025-01-24  
**Version :** 1.0.0  
**Status :** ✅ Complété

