# Documentation du Cache Local Hive

## Vue d'ensemble

Le système de cache local avec Hive permet à l'application Sahabi Guide de fonctionner en mode hors-ligne. Les données des rituels et des duas sont automatiquement synchronisées depuis le backend et stockées localement.

## Architecture

### Composants principaux

1. **HiveCacheService** : Gère le stockage et la récupération des données dans Hive
2. **ConnectivityService** : Surveille l'état de la connexion internet
3. **RitualsLocalDataSourceHive** : Interface entre le repository et Hive
4. **RitualsRepositoryImplWithSync** : Gère la logique de synchronisation automatique

### Flux de données

```
Backend API ──> RitualsRepository ──> HiveCacheService ──> Hive Boxes
                       ↓
                  ConnectivityService (surveille la connexion)
                       ↓
                  Synchronisation automatique
```

## Fonctionnalités

### 1. Cache Offline-First

- Les données sont chargées depuis le cache en priorité pour une UI réactive
- Si une connexion est disponible, les données sont synchronisées en arrière-plan
- L'utilisateur peut toujours accéder aux données même sans connexion

### 2. Synchronisation Automatique

La synchronisation se déclenche automatiquement dans les cas suivants :
- Au démarrage de l'application
- Quand la connexion internet est rétablie
- Après un `forceRefresh` explicite

### 3. Gestion de la version du contenu

Le système utilise `contentVersion` pour déterminer si les données locales sont à jour :
```dart
// Le backend retourne une version de contenu
final rituals = await repository.getRituals(); // Vérifie automatiquement

// Force un rafraîchissement
final rituals = await repository.getRituals(forceRefresh: true);
```

### 4. Expiration du cache

Par défaut, le cache expire après 7 jours. Le service nettoie automatiquement les données expirées.

## Utilisation

### Initialisation

L'initialisation se fait automatiquement dans `injection_container.dart` :

```dart
// Initialiser Hive
await Hive.initFlutter();

// Enregistrer les adapters
Hive.registerAdapter(RitualTypeAdapter());
Hive.registerAdapter(RitualStatusAdapter());
Hive.registerAdapter(RitualModelAdapter());
Hive.registerAdapter(DuaTypeAdapter());
Hive.registerAdapter(DuaModelAdapter());

// Initialiser le service
final hiveCacheService = HiveCacheService();
await hiveCacheService.initialize();
```

### Accès aux données

```dart
// Dans un widget ou un use case
final getRitualsUseCase = sl<GetRitualsUseCase>();

// Récupérer les rituels (cache-first)
final rituals = await getRitualsUseCase();

// Forcer un rafraîchissement depuis l'API
final freshRituals = await repository.getRituals(forceRefresh: true);
```

### Écouter les mises à jour

```dart
final repository = sl<RitualsRepository>() as RitualsRepositoryImplWithSync;

// Écouter les mises à jour des rituels
repository.ritualsUpdates.listen((rituals) {
  print('Nouveaux rituels disponibles: ${rituals.length}');
});

// Écouter les mises à jour des duas
repository.duasUpdates.listen((duas) {
  print('Nouvelles duas disponibles: ${duas.length}');
});
```

### Synchronisation manuelle

```dart
final repository = sl<RitualsRepository>() as RitualsRepositoryImplWithSync;

// Forcer une synchronisation complète
await repository.syncAll();
```

### Statistiques du cache

```dart
final hiveCacheService = sl<HiveCacheService>();

final stats = await hiveCacheService.getCacheStats();
print('Rituels en cache: ${stats['rituals']['count']}');
print('Dernière mise à jour: ${stats['rituals']['lastUpdate']}');
print('Cache valide: ${stats['rituals']['isValid']}');
```

### Nettoyage du cache

```dart
final hiveCacheService = sl<HiveCacheService>();

// Nettoyer tout le cache
await hiveCacheService.clearAll();

// Nettoyer uniquement le cache expiré
await hiveCacheService.clearExpiredCache();
```

## Stratégie de cache

### Mode Online

1. Charger depuis le cache immédiatement (UI rapide)
2. Vérifier la connexion internet
3. Si connecté, fetch depuis l'API en arrière-plan
4. Mettre à jour le cache avec les nouvelles données
5. Notifier l'UI des mises à jour

### Mode Offline

1. Charger depuis le cache
2. Afficher les données locales
3. Écouter les changements de connectivité
4. Dès que la connexion est rétablie, synchroniser automatiquement

### Gestion des erreurs

```dart
try {
  final rituals = await repository.getRituals();
} catch (e) {
  // L'erreur n'est lancée que si:
  // - Le cache est vide ET
  // - L'API n'est pas accessible
  
  // Sinon, le cache est utilisé comme fallback
}
```

## Configuration

### Durée de validité du cache

Modifier dans `hive_cache_service.dart` :

```dart
static const Duration _defaultCacheDuration = Duration(days: 7);
```

### Boxes Hive

Trois boxes sont utilisées :
- `rituals` : Stocke les rituels
- `duas` : Stocke les duas
- `cache_metadata` : Stocke les métadonnées (version, timestamp, etc.)

## Types d'adaptateurs Hive

### TypeIds utilisés

- `0` : RitualType
- `1` : RitualStatus
- `2` : RitualModel
- `3` : DuaType
- `4` : DuaModel

⚠️ **Important** : Ne jamais réutiliser un typeId déjà assigné, même si l'adapter est supprimé.

## Meilleures pratiques

### 1. Toujours vérifier l'initialisation

```dart
if (!hiveCacheService.isInitialized) {
  await hiveCacheService.initialize();
}
```

### 2. Utiliser le repository au lieu d'accéder directement au cache

```dart
// ✅ Recommandé
final rituals = await repository.getRituals();

// ❌ À éviter
final rituals = await hiveCacheService.getRituals();
```

### 3. Gérer la disposition des ressources

```dart
// À la fermeture de l'application
final hiveCacheService = sl<HiveCacheService>();
await hiveCacheService.dispose();

final connectivityService = sl<ConnectivityService>();
connectivityService.dispose();
```

### 4. Tester avec et sans connexion

Toujours tester l'application dans les deux modes :
- Mode online : vérifier la synchronisation
- Mode offline : vérifier l'accès aux données en cache

## Dépannage

### Problème : Les données ne se synchronisent pas

**Vérifications** :
1. Le ConnectivityService est-il initialisé ?
2. La connexion internet est-elle réellement disponible ?
3. L'API backend est-elle accessible ?

```dart
final connectivity = sl<ConnectivityService>();
print('Connecté: ${connectivity.isConnected}');
print('Type: ${await connectivity.getConnectionType()}');
```

### Problème : Erreur "Box not initialized"

**Solution** : Assurez-vous que `initialize()` est appelé avant toute opération :

```dart
final hiveCacheService = sl<HiveCacheService>();
await hiveCacheService.initialize();
```

### Problème : Cache corrompu

**Solution** : Nettoyer le cache et forcer un rafraîchissement :

```dart
await hiveCacheService.clearAll();
await repository.getRituals(forceRefresh: true);
```

## Performance

### Benchmarks approximatifs

- Chargement depuis Hive : ~10-50ms pour 100 objets
- Chargement depuis SharedPreferences : ~100-500ms pour 100 objets
- Fetch depuis l'API : ~500-2000ms (dépend de la connexion)

### Optimisations

1. **Lazy Loading** : Charger uniquement les données nécessaires
2. **Batch Operations** : Utiliser `putAll` au lieu de `put` en boucle
3. **Compression** : Hive compresse automatiquement les données
4. **Index** : Les clés sont indexées pour un accès rapide

## Migration depuis SharedPreferences

Si vous avez des données existantes dans SharedPreferences :

```dart
// Lire les anciennes données
final oldCacheService = sl<CacheService>();
final oldRituals = await oldCacheService.get<List<dynamic>>('rituals_list');

if (oldRituals != null) {
  // Migrer vers Hive
  final rituals = oldRituals.data
      .map((json) => RitualModel.fromJson(json))
      .toList();
  
  await hiveCacheService.saveRituals(rituals);
  
  // Nettoyer l'ancien cache
  await oldCacheService.clear('rituals_list');
}
```

## Références

- [Documentation Hive](https://docs.hivedb.dev/)
- [Flutter Offline-First](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#offline-first)
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus)

