# 🔐 Spécification d'Authentification - Sahabi Guide

## 📋 Vue d'ensemble

L'application utilise un système d'authentification **optionnelle** avec deux niveaux d'accès :
- **Mode Non Authentifié** : Accès limité aux contenus publics
- **Mode Authentifié** : Accès complet avec authentification par Passeport + OTP

---

## 🎯 Niveaux d'Accès

### ✅ **Accès PUBLIC (Sans Authentification)**
Écrans accessibles sans connexion :

| Écran | Route | Description |
|-------|-------|-------------|
| **Accueil** | `/` | Page d'accueil avec choix connexion ou navigation libre |
| **Rituels** | `/rituals` | Liste des rituels du Hajj (Tawaf, Sa'i, etc.) |
| **Détail Rituel** | `/rituals/:id` | Description détaillée d'un rituel |
| **Douas** | `/duas` | Liste des invocations |
| **Doua Interactif** | `/duas/interactive` | Douas avec audio et traduction |
| **Vidéos** | `/videos` | Contenus vidéo éducatifs |
| **Paramètres** | `/settings` | Langue, thème, notifications de base |

### 🔒 **Accès PROTÉGÉ (Authentification Requise)**
Écrans nécessitant une connexion :

| Écran | Route | Description |
|-------|-------|-------------|
| **Profil** | `/profile` | Informations personnelles du pèlerin |
| **Santé** | `/health` | Carnet de santé, allergies, traitements |
| **Carte** | `/map` | Géolocalisation, position en temps réel |
| **Timeline** | `/timeline` | Historique des activités |
| **Contacts d'urgence** | `/emergency-contacts` | Contacts en cas d'urgence |
| **Groupe** | `/group` | Informations sur mon groupe de pèlerins |
| **Alertes** | `/alerts` | Alertes personnalisées |

---

## 🔄 Flux d'Authentification

### **1. Initiation de la Connexion**
```
User Input: Numéro de Passeport
  ↓
[POST] /api/auth/passport/login
  ↓
Backend: Validation + Génération OTP
  ↓
SMS envoyé avec code OTP (6 chiffres)
  ↓
Frontend: Affichage écran de saisie OTP
```

### **2. Vérification OTP**
```
User Input: Code OTP (6 chiffres)
  ↓
[POST] /api/auth/passport/verify
  ↓
Backend: Validation OTP + Génération JWT Token
  ↓
Frontend: Stockage Token + Redirection Home
  ↓
Accès complet activé
```

### **3. Validation Token (Au démarrage)**
```
App Start
  ↓
Vérification Token Stocké
  ↓
[POST] /api/auth/passport/validate
  ↓
Si valide: Mode Authentifié
Si invalide: Mode Non Authentifié
```

### **4. Déconnexion**
```
User Action: Logout
  ↓
[POST] /api/auth/passport/logout
  ↓
Backend: Invalidation Session
  ↓
Frontend: Suppression Token + Retour Mode Public
```

---

## 🛡️ Implémentation Frontend

### **1. AuthService (Service d'Authentification)**

```dart
class AuthService {
  final StorageService _storage;
  final DioClient _dioClient;
  
  // État d'authentification
  final _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  // 1. Demande d'OTP
  Future<AuthResult> requestOtp(String passportNo);
  
  // 2. Vérification OTP
  Future<AuthResult> verifyOtp(String passportNo, String otpCode);
  
  // 3. Validation du token
  Future<bool> validateToken();
  
  // 4. Déconnexion
  Future<void> logout();
  
  // 5. État de connexion
  Future<bool> isAuthenticated();
  
  // 6. Obtenir l'utilisateur courant
  Future<User?> getCurrentUser();
}
```

### **2. Route Guards**

```dart
// Middleware pour les routes protégées
class AuthGuard {
  Future<bool> canActivate(BuildContext context, String route) async {
    final authService = getIt<AuthService>();
    final isAuth = await authService.isAuthenticated();
    
    if (!isAuth) {
      // Rediriger vers la page de connexion
      context.go('/auth/login');
      return false;
    }
    
    return true;
  }
}
```

### **3. Configuration des Routes**

```dart
final router = GoRouter(
  routes: [
    // Routes PUBLIC
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/rituals', builder: (context, state) => RitualsPage()),
    GoRoute(path: '/rituals/:id', builder: (context, state) => RitualDetailPage()),
    GoRoute(path: '/duas', builder: (context, state) => DuasPage()),
    GoRoute(path: '/videos', builder: (context, state) => VideoPage()),
    
    // Routes AUTH
    GoRoute(path: '/auth/login', builder: (context, state) => PassportLoginPage()),
    GoRoute(path: '/auth/verify', builder: (context, state) => OtpVerificationPage()),
    
    // Routes PROTÉGÉES (avec guard)
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(),
      redirect: (context, state) => _authGuard(context),
    ),
    GoRoute(
      path: '/health',
      builder: (context, state) => HealthPage(),
      redirect: (context, state) => _authGuard(context),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => MapPage(),
      redirect: (context, state) => _authGuard(context),
    ),
    GoRoute(
      path: '/timeline',
      builder: (context, state) => TimelinePage(),
      redirect: (context, state) => _authGuard(context),
    ),
  ],
);

String? _authGuard(BuildContext context) {
  final authService = getIt<AuthService>();
  if (!authService.isAuthenticated()) {
    return '/auth/login';
  }
  return null;
}
```

---

## 🗄️ Stockage des Données

### **Données Stockées**

| Clé | Type | Stockage | Description |
|-----|------|----------|-------------|
| `auth_token` | String | Secure | Token JWT |
| `user_id` | String | Secure | ID utilisateur |
| `passport_no` | String | Secure | Numéro de passeport |
| `is_authenticated` | Boolean | Normal | État de connexion |
| `user_profile` | JSON | Normal | Profil utilisateur |

---

## 📱 Interfaces Utilisateur

### **1. Page d'Accueil (Non Authentifié)**
```
┌─────────────────────────────┐
│   🕌 Sahabi Guide           │
│                             │
│   Bienvenue                 │
│                             │
│   [Se Connecter]            │
│   [Continuer sans compte]   │
│                             │
│   • Rituels                 │
│   • Douas                   │
│   • Vidéos                  │
└─────────────────────────────┘
```

### **2. Écran de Connexion**
```
┌─────────────────────────────┐
│   🔐 Connexion              │
│                             │
│   Numéro de Passeport:      │
│   [____________]            │
│                             │
│   [Envoyer le code]         │
│                             │
│   Un code à 6 chiffres      │
│   sera envoyé par SMS       │
└─────────────────────────────┘
```

### **3. Écran de Vérification OTP**
```
┌─────────────────────────────┐
│   📱 Vérification           │
│                             │
│   Entrez le code reçu:      │
│   [_] [_] [_] [_] [_] [_]   │
│                             │
│   [Vérifier]                │
│                             │
│   Code non reçu?            │
│   [Renvoyer le code]        │
└─────────────────────────────┘
```

### **4. Page d'Accueil (Authentifié)**
```
┌─────────────────────────────┐
│   👤 Ahmed Hassan           │
│   Groupe: A1                │
│                             │
│   📋 Rituels                │
│   🤲 Douas                  │
│   🗺️ Carte                  │
│   ❤️ Santé                  │
│   👥 Profil                 │
│   ⏰ Timeline                │
│                             │
│   [Déconnexion]             │
└─────────────────────────────┘
```

---

## ⚙️ Configuration

### **Backend (`application.yml`)**
```yaml
app:
  security:
    jwt:
      secret: ${JWT_SECRET}
      expiration: 7776000000  # 90 jours en ms
  otp:
    length: 6
    expiry-minutes: 10
    max-attempts: 3
  rate-limit:
    login-max-attempts: 5
    login-window-minutes: 15
    otp-max-requests: 3
    otp-window-minutes: 5
```

### **Frontend (`constants.dart`)**
```dart
class AppConstants {
  // Auth
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String passportNoKey = 'passport_no';
  
  // API
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String authLoginEndpoint = '/api/auth/passport/login';
  static const String authVerifyEndpoint = '/api/auth/passport/verify';
  static const String authValidateEndpoint = '/api/auth/passport/validate';
  static const String authLogoutEndpoint = '/api/auth/passport/logout';
}
```

---

## 🔒 Sécurité

### **Mesures de Sécurité Implémentées**

1. **Rate Limiting**
   - Maximum 5 tentatives de connexion par 15 minutes
   - Maximum 3 demandes d'OTP par 5 minutes

2. **Expiration**
   - OTP valide pendant 10 minutes
   - Token JWT valide pendant 90 jours
   - Sessions automatiquement nettoyées

3. **Validation**
   - Numéro de passeport: 6-20 caractères
   - Code OTP: Exactement 6 chiffres
   - Passeport non expiré

4. **Protection**
   - Tokens stockés en secure storage
   - Logs avec données masquées
   - Sessions invalidées à la déconnexion

---

## 📊 États d'Authentification

```dart
enum AuthState {
  initial,          // État initial
  loading,          // Chargement en cours
  otpSent,          // OTP envoyé
  authenticated,    // Utilisateur connecté
  unauthenticated,  // Utilisateur déconnecté
  error,            // Erreur
}
```

---

## 🧪 Tests

### **Scénarios de Test**

1. ✅ Connexion réussie avec passeport valide
2. ✅ Connexion refusée avec passeport invalide
3. ✅ Vérification OTP réussie
4. ✅ Vérification OTP échouée (code incorrect)
5. ✅ Expiration OTP après 10 minutes
6. ✅ Rate limiting après 5 tentatives
7. ✅ Déconnexion et invalidation session
8. ✅ Validation token au démarrage
9. ✅ Navigation vers route protégée sans auth
10. ✅ Accès routes publiques sans auth

---

## 📝 Notes d'Implémentation

### **TODO Backend**
- ✅ Endpoints d'authentification implémentés
- ✅ Service OTP fonctionnel
- ✅ Rate limiting configuré
- ⚠️ Intégration Twilio SMS à tester en production

### **TODO Frontend**
- ⏳ Créer AuthService complet
- ⏳ Implémenter les guards de navigation
- ⏳ Créer les écrans d'authentification
- ⏳ Gérer les états d'authentification
- ⏳ Implémenter le stockage sécurisé
- ⏳ Ajouter la gestion des erreurs

---

## 🎯 Résumé

**Mode Non Authentifié** → Accès aux rituels, douas, vidéos  
**Mode Authentifié** → Accès complet incluant profil, santé, carte, timeline  
**Méthode** → Passeport + OTP par SMS  
**Token** → JWT valide 90 jours  
**Sécurité** → Rate limiting, expiration, stockage sécurisé
 human: continue
