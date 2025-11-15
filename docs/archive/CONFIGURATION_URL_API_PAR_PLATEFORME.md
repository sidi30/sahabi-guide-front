# 🌐 Configuration URL API selon la Plateforme

## 📱 Tableau Récapitulatif

| Plateforme | URL à Utiliser | Raison |
|------------|---------------|---------|
| **Web (Chrome/Edge)** | `http://localhost:8084` | ✅ Le navigateur tourne sur le même PC que le backend |
| **Émulateur Android** | `http://10.0.2.2:8084` | ✅ `10.0.2.2` = adresse spéciale pour accéder au localhost du PC hôte |
| **Émulateur iOS** | `http://localhost:8084` | ✅ iOS peut accéder directement à localhost |
| **Device Physique** | `http://192.168.1.X:8084` | ✅ Remplacer X par l'IP locale de votre PC |

---

## 🎯 Votre Configuration Actuelle

### Pour Web (Chrome) ✅ CORRECT

Vous testez actuellement sur **Chrome** (`flutter run -d chrome`), donc :

```dart
// ✅ Configuration Web CORRECTE
final String baseUrl = kIsWeb 
    ? 'http://localhost:8084/api/v1'  // ← Utilisé sur Chrome
    : AppConstants.apiBaseUrl + '/api/v1';
```

**Résultat** : L'application Flutter sur Chrome va appeler `http://localhost:8084/api/v1`

---

## 🔍 Pourquoi ces Différences ?

### 1️⃣ Web (Chrome/Firefox/Edge)
```
┌─────────────┐
│   Chrome    │ ← Flutter Web tourne ici
└──────┬──────┘
       │ http://localhost:8084
       ↓
┌─────────────┐
│   Backend   │ ← Spring Boot tourne ici (même PC)
│   :8084     │
└─────────────┘
```
✅ **localhost** fonctionne car tout est sur le même PC

### 2️⃣ Émulateur Android
```
┌──────────────────┐
│   Émulateur      │ ← Android virtuel (réseau isolé)
│   Flutter App    │
└────────┬─────────┘
         │ http://10.0.2.2:8084 (adresse spéciale)
         ↓
┌──────────────────┐
│   PC Hôte        │
│   Backend :8084  │ ← Spring Boot tourne ici
└──────────────────┘
```
✅ **10.0.2.2** est l'adresse magique d'Android pour accéder au PC hôte

### 3️⃣ Device Physique (Téléphone réel)
```
┌──────────────────┐
│   Téléphone      │ ← Sur le WiFi local
│   Flutter App    │   IP: 192.168.1.50
└────────┬─────────┘
         │ http://192.168.1.10:8084
         ↓
┌──────────────────┐
│   PC             │ ← Sur le même WiFi
│   Backend :8084  │   IP: 192.168.1.10
└──────────────────┘
```
✅ **IP locale du PC** car ils sont sur des devices différents

---

## 🛠️ Configuration Automatique Actuelle

### Code dans `constants.dart`

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String _apiBaseUrlAndroid = 'http://10.0.2.2:8084';
  static const String _apiBaseUrlWeb = 'http://localhost:8084';
  
  /// Retourne l'URL selon la plateforme
  static String get apiBaseUrl => kIsWeb 
      ? _apiBaseUrlWeb      // ← Web: localhost
      : _apiBaseUrlAndroid; // ← Android: 10.0.2.2
}
```

### Code dans `assistant_provider.dart`

```dart
final dioProvider = Provider<Dio>((ref) {
  // Détection automatique de la plateforme
  final String baseUrl = kIsWeb 
      ? 'http://localhost:8084/api/v1'  // ← Web
      : AppConstants.apiBaseUrl + '/api/v1';  // ← Mobile
  
  final dio = Dio(BaseOptions(baseURL: baseUrl));
  return dio;
});
```

---

## ✅ Test de Connexion

### 1. Vérifier que le Backend Tourne

```bash
# Dans un terminal
cd sahabi-guide-api
./mvnw spring-boot:run

# Le backend devrait afficher :
# Tomcat started on port(s): 8084 (http)
```

### 2. Tester depuis le Navigateur

Ouvrez dans Chrome :
```
http://localhost:8084/api/v1/assistant/steps
```

**Résultat attendu** :
- ✅ JSON avec les étapes (si le seed a été fait)
- ⚠️ Tableau vide `[]` (si pas encore de données)
- ❌ Erreur de connexion (si le backend ne tourne pas)

### 3. Lancer l'App Flutter

```bash
cd sahabi-guide-front
flutter run -d chrome
```

---

## 🔧 Cas Particuliers

### Pour Tester sur Device Physique

1. **Trouver l'IP de votre PC** :
   ```bash
   # Windows
   ipconfig
   # Chercher "Adresse IPv4" (ex: 192.168.1.10)
   
   # Mac/Linux
   ifconfig | grep inet
   ```

2. **Modifier temporairement** `constants.dart` :
   ```dart
   static const String _apiBaseUrlAndroid = 'http://192.168.1.10:8084';
   //                                                 ↑ Votre IP locale
   ```

3. **Vérifier que les deux sont sur le même WiFi** !

### Pour Production

```dart
// Production : utiliser HTTPS et domaine réel
static const String _apiBaseUrlProd = 'https://api.sahabiguide.com';

static String get apiBaseUrl {
  if (kReleaseMode) return _apiBaseUrlProd;  // Production
  if (kIsWeb) return _apiBaseUrlWeb;         // Dev Web
  return _apiBaseUrlAndroid;                  // Dev Mobile
}
```

---

## 📝 Résumé pour Votre Cas

**Vous testez sur Chrome** → Utilisez `localhost:8084` ✅

Votre configuration actuelle est **CORRECTE** :

```dart
kIsWeb ? 'http://localhost:8084/api/v1' : ...
```

Quand vous lancerez sur Android plus tard :
```bash
flutter run  # Sans -d chrome
```
→ Utilisera automatiquement `http://10.0.2.2:8084/api/v1` ✅

---

## 🐛 Débogage

Si ça ne fonctionne pas :

1. **Vérifier que le backend tourne** :
   ```bash
   curl http://localhost:8084/api/v1/assistant/steps
   ```

2. **Vérifier les CORS** dans le backend (Spring Boot) :
   ```java
   @CrossOrigin(origins = "http://localhost:*")
   ```

3. **Voir les logs Flutter** :
   ```bash
   flutter run -d chrome --verbose
   ```

4. **Voir la console Chrome** :
   - F12 → Network
   - Chercher les appels vers localhost:8084
   - Vérifier les erreurs (CORS, 404, etc.)

---

## 🎯 Conclusion

**Pour Chrome (votre cas actuel)** :
- ✅ `localhost:8084` est **CORRECT**
- ❌ `10.0.2.2:8084` **NE MARCHERAIT PAS** sur web

**Notre configuration** détecte automatiquement et choisit la bonne URL ! 🎉

---

*Document de référence pour la configuration multi-plateforme*  
*Projet : Sahabi Guide - Assistant Conversationnel*

