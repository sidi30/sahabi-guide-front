# 📋 Plan de Refonte Détaillé - Application Flutter Sahabi Guide

**Date**: 22 Octobre 2025  
**Basé sur**: AUDIT_FLUTTER_NETTOYAGE_COMPLET.md  
**Objectif**: Nettoyage systématique du code redondant

---

## 🎯 Vue d'Ensemble

Ce plan détaille les étapes précises pour nettoyer l'application Flutter et la rendre plus maintenable.

**Durée totale estimée** : 1h30  
**Impact** : -4000 lignes de code (-22%)  
**Risque** : Faible (code inutilisé)

---

## 📦 PHASE 1 : Suppression des Pages d'Authentification Inutilisées

**Durée** : 10 minutes  
**Priorité** : 🔴 HAUTE  
**Impact** : ~900 lignes supprimées

### Fichiers à Supprimer :

```bash
# Pages inutilisées
sahabi-guide-front/lib/features/auth/presentation/pages/login_page.dart
sahabi-guide-front/lib/features/auth/presentation/pages/register_page.dart
sahabi-guide-front/lib/features/auth/presentation/pages/otp_verification_page.dart

# Use cases inutilisés
sahabi-guide-front/lib/features/auth/domain/usecases/login_usecase.dart
sahabi-guide-front/lib/features/auth/domain/usecases/register_usecase.dart
sahabi-guide-front/lib/features/auth/domain/usecases/logout_usecase.dart
```

### Vérifications :
- [ ] Vérifier qu'aucun import de ces fichiers existe : `grep -r "import.*login_page.dart" lib/`
- [ ] Vérifier qu'aucun import de ces fichiers existe : `grep -r "import.*register_page.dart" lib/`
- [ ] Vérifier qu'aucun import de ces fichiers existe : `grep -r "import.*otp_verification_page.dart" lib/`

### Commandes :
```bash
cd sahabi-guide-front
rm lib/features/auth/presentation/pages/login_page.dart
rm lib/features/auth/presentation/pages/register_page.dart
rm lib/features/auth/presentation/pages/otp_verification_page.dart
rm lib/features/auth/domain/usecases/login_usecase.dart
rm lib/features/auth/domain/usecases/register_usecase.dart
rm lib/features/auth/domain/usecases/logout_usecase.dart
```

---

## 🗺️ PHASE 2 : Suppression des Pages Map Redondantes

**Durée** : 5 minutes  
**Priorité** : 🔴 HAUTE  
**Impact** : ~1500 lignes supprimées

### Fichiers à Supprimer :

```bash
sahabi-guide-front/lib/features/map/presentation/pages/map_page.dart
sahabi-guide-front/lib/features/map/presentation/pages/map_page_new.dart
```

### Page à Conserver :
```
✅ sahabi-guide-front/lib/features/map/presentation/pages/google_map_page.dart
```

### Vérifications :
- [ ] Confirmer que seul `google_map_page.dart` est importé dans `main.dart`
- [ ] Vérifier qu'aucun autre import existe

### Commandes :
```bash
cd sahabi-guide-front
rm lib/features/map/presentation/pages/map_page.dart
rm lib/features/map/presentation/pages/map_page_new.dart
```

---

## 📱 PHASE 3 : Suppression des Pages Connectivity & Duas Redondantes

**Durée** : 5 minutes  
**Priorité** : 🟡 MOYENNE  
**Impact** : ~880 lignes supprimées

### Fichiers à Supprimer :

```bash
# Connectivity ancienne version
sahabi-guide-front/lib/features/connectivity/presentation/pages/connectivity_page.dart

# Duas ancienne version
sahabi-guide-front/lib/features/duas/presentation/pages/duas_page.dart
```

### Pages à Conserver :
```
✅ sahabi-guide-front/lib/features/connectivity/presentation/pages/connectivity_esim_page.dart
✅ sahabi-guide-front/lib/features/rituals/presentation/pages/duas_modern_page.dart
```

### Vérifications :
- [ ] Vérifier que `connectivity_esim_page.dart` est utilisée dans `main.dart`
- [ ] Vérifier que `duas_modern_page.dart` est utilisée dans `main.dart`

### Commandes :
```bash
cd sahabi-guide-front
rm lib/features/connectivity/presentation/pages/connectivity_page.dart
rm lib/features/duas/presentation/pages/duas_page.dart
```

---

## 🎭 PHASE 4 : Suppression de la Page Rituals Timeline et Providers

**Durée** : 5 minutes  
**Priorité** : 🟡 MOYENNE  
**Impact** : ~742 lignes supprimées

### Fichiers à Supprimer :

```bash
# Page inutilisée (utilise Provider)
sahabi-guide-front/lib/features/rituals/presentation/pages/ritual_timeline_page.dart

# Providers inutilisés (ChangeNotifier)
sahabi-guide-front/lib/features/rituals/presentation/providers/rituals_state_manager.dart
sahabi-guide-front/lib/features/duas/presentation/providers/duas_provider.dart
```

### Page à Conserver :
```
✅ sahabi-guide-front/lib/features/rituals/presentation/pages/rituals_page.dart (Riverpod)
```

### Vérifications :
- [ ] Vérifier qu'aucun import de `ritual_timeline_page.dart`
- [ ] Vérifier qu'aucun import de `rituals_state_manager.dart`
- [ ] Vérifier qu'aucun import de `duas_provider.dart`

### Commandes :
```bash
cd sahabi-guide-front
rm lib/features/rituals/presentation/pages/ritual_timeline_page.dart
rm lib/features/rituals/presentation/providers/rituals_state_manager.dart
rm lib/features/duas/presentation/providers/duas_provider.dart
```

---

## 📄 PHASE 5 : Suppression de la Page Menu Inutilisée

**Durée** : 2 minutes  
**Priorité** : 🟢 FAIBLE  
**Impact** : ~322 lignes supprimées

### Fichiers à Supprimer :

```bash
sahabi-guide-front/lib/features/home/presentation/pages/menu_page.dart
```

### Page à Conserver :
```
✅ sahabi-guide-front/lib/features/home/presentation/pages/home_page.dart
```

### Vérifications :
- [ ] Vérifier qu'aucun import de `menu_page.dart`

### Commandes :
```bash
cd sahabi-guide-front
rm lib/features/home/presentation/pages/menu_page.dart
```

---

## 🔐 PHASE 6 : Fusion des Datasources d'Authentification

**Durée** : 15 minutes  
**Priorité** : 🟡 MOYENNE  
**Impact** : Amélioration de la cohérence + ~50 lignes

### Objectif :
Supprimer `auth_local_data_source.dart` et utiliser uniquement `passport_auth_local_data_source.dart`

### Étapes :

1. **Vérifier les usages** de `AuthLocalDataSource` :
```bash
grep -r "AuthLocalDataSource" lib/
```

2. **Analyser les dépendances** :
   - Qui utilise `AuthLocalDataSource` ?
   - Peut-on migrer vers `PassportAuthLocalDataSource` ?

3. **Supprimer si inutilisé** :
```bash
rm lib/features/auth/data/datasources/auth_local_data_source.dart
```

4. **Mettre à jour injection_container.dart** si nécessaire

### Vérifications :
- [ ] Vérifier qu'aucun code ne référence `AuthLocalDataSource`
- [ ] Vérifier que `PassportAuthLocalDataSource` couvre tous les besoins
- [ ] Tester le flux d'authentification

---

## 📦 PHASE 7 : Nettoyage des Dépendances

**Durée** : 20 minutes  
**Priorité** : 🟢 FAIBLE  
**Impact** : Bundle plus léger + cohérence

### 7.1 Supprimer la Dépendance Provider

**Fichier** : `sahabi-guide-front/pubspec.yaml`

```yaml
# AVANT
dependencies:
  flutter_riverpod: ^2.4.9
  provider: ^6.1.2  # ❌ À SUPPRIMER

# APRÈS
dependencies:
  flutter_riverpod: ^2.4.9
  # provider supprimé ✅
```

### Vérifications :
- [ ] Vérifier qu'aucun fichier n'importe `package:provider/provider.dart`
- [ ] Exécuter `flutter pub get`
- [ ] Compiler l'application

---

### 7.2 Migrer DuasRemoteDataSource vers DioClient

**Objectif** : Supprimer la dépendance `http` et utiliser uniquement `dio`

#### Étapes :

1. **Modifier** `duas_remote_data_source.dart` :
```dart
// AVANT
import 'package:http/http.dart' as http;

class DuasRemoteDataSourceImpl implements DuasRemoteDataSource {
  final http.Client client;
  DuasRemoteDataSourceImpl({required this.client});
}

// APRÈS
import '../../../../core/network/dio_client.dart';

class DuasRemoteDataSourceImpl implements DuasRemoteDataSource {
  final DioClient dioClient;
  DuasRemoteDataSourceImpl({required this.dioClient});
}
```

2. **Mettre à jour les appels** :
```dart
// AVANT
final response = await client.get(uri, headers: {...});

// APRÈS
final response = await dioClient.get('/api/v1/duas', queryParameters: {...});
```

3. **Mettre à jour injection_container.dart**

4. **Supprimer la dépendance http** de `pubspec.yaml` :
```yaml
# AVANT
dependencies:
  dio: ^5.4.0
  http: ^1.1.0  # ❌ À SUPPRIMER

# APRÈS
dependencies:
  dio: ^5.4.0
```

### Vérifications :
- [ ] Vérifier qu'aucun fichier n'importe `package:http/http.dart`
- [ ] Tester le chargement des duas
- [ ] Exécuter `flutter pub get`

---

## ✅ PHASE 8 : Vérification et Tests

**Durée** : 30 minutes  
**Priorité** : 🔴 CRITIQUE  
**Impact** : Garantie de stabilité

### Tests Fonctionnels :

#### 8.1 Authentification
- [ ] Lancer l'application
- [ ] Tester le login avec un numéro de passeport valide
- [ ] Vérifier la réception de l'OTP
- [ ] Vérifier la validation de l'OTP
- [ ] Vérifier la redirection vers `/home`

#### 8.2 Navigation
- [ ] Tester la navigation vers chaque écran depuis le BottomNav
- [ ] Vérifier que la page Map s'affiche correctement
- [ ] Vérifier que la page Rituals charge les données
- [ ] Vérifier que la page Duas charge les données
- [ ] Vérifier que la page Connectivity s'affiche

#### 8.3 Compilation
```bash
cd sahabi-guide-front
flutter clean
flutter pub get
flutter pub upgrade
flutter analyze
flutter build apk --debug  # ou flutter build ios
```

#### 8.4 Vérification des Imports Cassés
```bash
# Vérifier qu'aucun import cassé
grep -r "import.*login_page.dart" lib/
grep -r "import.*register_page.dart" lib/
grep -r "import.*otp_verification_page.dart" lib/
grep -r "import.*map_page.dart" lib/
grep -r "import.*map_page_new.dart" lib/
grep -r "import.*connectivity_page.dart" lib/
grep -r "import.*duas_page.dart" lib/
grep -r "import.*ritual_timeline_page.dart" lib/
grep -r "import.*menu_page.dart" lib/
grep -r "import.*rituals_state_manager.dart" lib/
grep -r "import 'package:provider/" lib/
grep -r "import 'package:http/" lib/
```

### Résultats Attendus :
- [ ] Aucune erreur de compilation
- [ ] Aucun import cassé
- [ ] `flutter analyze` retourne 0 erreur
- [ ] L'application se lance sans crash
- [ ] Le flux d'authentification fonctionne
- [ ] Toutes les pages principales sont accessibles

---

## 📊 Résumé des Suppressions

| Phase | Fichiers Supprimés | Lignes | Temps |
|-------|-------------------|--------|-------|
| 1. Auth Pages | 6 fichiers | ~900 | 10 min |
| 2. Map Pages | 2 fichiers | ~1500 | 5 min |
| 3. Connectivity & Duas | 2 fichiers | ~880 | 5 min |
| 4. Rituals & Providers | 3 fichiers | ~742 | 5 min |
| 5. Menu Page | 1 fichier | ~322 | 2 min |
| 6. Auth Datasource | 1 fichier | ~50 | 15 min |
| 7. Dépendances | Refactoring | - | 20 min |
| 8. Tests | - | - | 30 min |
| **TOTAL** | **15 fichiers** | **~4394** | **1h32** |

---

## 🎉 Résultats Attendus Post-Refonte

### Métriques
- **-15 fichiers** supprimés
- **-4394 lignes de code** (-22%)
- **-2 dépendances** (provider, http)
- **100% Riverpod** (state management unifié)
- **100% Dio** (client HTTP unifié)

### Qualité du Code
- ✅ Architecture cohérente
- ✅ Pas de code mort
- ✅ Pas de duplication
- ✅ État de l'art Flutter 2025
- ✅ Facile à maintenir

### Performance
- ✅ Bundle plus léger
- ✅ Moins de dépendances
- ✅ Compilation plus rapide
- ✅ Moins de mémoire utilisée

---

## 🚨 Points d'Attention

### Risques Potentiels

1. **Import Cassé** : Vérifier soigneusement tous les imports
2. **Injection Container** : Mettre à jour si nécessaire après suppression
3. **Tests Existants** : Supprimer les tests des fichiers supprimés
4. **Documentation** : Mettre à jour si elle référence les anciens fichiers

### Rollback Plan

Si un problème survient :
```bash
# Restaurer depuis git
git restore sahabi-guide-front/lib/features/auth/presentation/pages/login_page.dart
# etc.
```

---

## 📝 Checklist Finale

Avant de considérer la refonte comme terminée :

- [ ] Tous les fichiers listés sont supprimés
- [ ] Aucun import cassé ne subsiste
- [ ] L'application se compile sans erreur
- [ ] Les tests fonctionnels passent
- [ ] `flutter analyze` retourne 0 erreur
- [ ] Les dépendances inutiles sont supprimées de pubspec.yaml
- [ ] Le fichier CHANGELOG.md est mis à jour
- [ ] Un commit propre est créé
- [ ] La documentation est mise à jour si nécessaire

---

## 🎯 Commande d'Exécution Complète

Pour exécuter toutes les phases en une seule fois (après validation) :

```bash
#!/bin/bash
cd sahabi-guide-front

echo "🗑️  Phase 1: Suppression des pages auth inutilisées..."
rm lib/features/auth/presentation/pages/login_page.dart
rm lib/features/auth/presentation/pages/register_page.dart
rm lib/features/auth/presentation/pages/otp_verification_page.dart
rm lib/features/auth/domain/usecases/login_usecase.dart
rm lib/features/auth/domain/usecases/register_usecase.dart
rm lib/features/auth/domain/usecases/logout_usecase.dart

echo "🗑️  Phase 2: Suppression des pages map redondantes..."
rm lib/features/map/presentation/pages/map_page.dart
rm lib/features/map/presentation/pages/map_page_new.dart

echo "🗑️  Phase 3: Suppression des pages connectivity & duas redondantes..."
rm lib/features/connectivity/presentation/pages/connectivity_page.dart
rm lib/features/duas/presentation/pages/duas_page.dart

echo "🗑️  Phase 4: Suppression de ritual_timeline et providers..."
rm lib/features/rituals/presentation/pages/ritual_timeline_page.dart
rm lib/features/rituals/presentation/providers/rituals_state_manager.dart
rm lib/features/duas/presentation/providers/duas_provider.dart

echo "🗑️  Phase 5: Suppression de menu_page..."
rm lib/features/home/presentation/pages/menu_page.dart

echo "✅ Nettoyage terminé ! Exécution de flutter clean et pub get..."
flutter clean
flutter pub get

echo "🔍 Analyse du code..."
flutter analyze

echo "✅ Refonte terminée avec succès !"
```

---

**Fin du Plan de Refonte** 🎉

