# Plan de corrections - Sahabi Guide Mobile

Audit verifie et confirme le 13 avril 2026. Toutes les issues existent dans le code.

---

## Phase 1 : Securite critique (3-4 jours)

### Jour 1 - Secrets et donnees sensibles

**S2 - Supprimer l'IP de prod du code source**
- `lib/core/config/env_config.dart` lignes 29, 32
- `lib/core/utils/constants.dart` ligne 11
- Remplacer les URLs hardcodees par des --dart-define injectees au build :
  ```dart
  // env_config.dart
  static const String apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
  ```
  ```bash
  flutter build apk --dart-define=API_URL=https://api.sahabiguide.com
  ```

**S3 - Supprimer les logs sensibles**
- `lib/features/auth/presentation/providers/passport_auth_provider.dart` ligne 150
- Supprimer ou conditionner avec kDebugMode :
  ```dart
  if (kDebugMode) AppLogger.debug('[AuthNotifier] ...');
  ```

**S7 + S8 - Migrer les donnees PII vers SecureStorage**
- `lib/shared/services/auth_service.dart` lignes 119, 425-427
- Remplacer `_storage.store()` (SharedPreferences) par `_secureStorage.write()` pour :
  - Numero de passeport
  - Donnees de profil utilisateur

### Jour 2 - Validation et tokens

**S4 - JWT : ne plus valider localement**
- `lib/core/utils/token_validator.dart` lignes 8-44
- Le client ne doit jamais faire confiance au contenu du JWT sans verifier la signature
- Solution : appeler un endpoint backend `/auth/validate` ou simplement verifier l'expiration + laisser le backend rejeter les tokens invalides via le 401
  ```dart
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000).isBefore(DateTime.now());
    } catch (_) {
      return true; // En cas d'erreur, considerer expire
    }
  }
  ```

**Q1 - Supprimer l'ID de test**
- `lib/features/alerts/presentation/pages/alerts_page.dart` ligne 38
- Remplacer par l'ID du profil authentifie :
  ```dart
  _pilgrimId = ref.read(authProvider).currentUser?.id ?? '';
  ```

### Jour 3 - Certificate pinning

**S1 + S6 - Implementer le certificate pinning**
- `lib/core/network/dio_client.dart`
- Ajouter le pinning SSL avec le hash du certificat de production :
  ```dart
  // Ajouter dans le constructeur DioClient
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Verifier le fingerprint SHA256
      final fingerprint = sha256.convert(cert.der).toString();
      return _trustedFingerprints.contains(fingerprint);
    };
    return client;
  };
  ```

- `android/app/src/main/res/xml/network_security_config.xml`
- Ajouter les pins pour le domaine de production :
  ```xml
  <domain-config>
    <domain includeSubdomains="true">sahabiguide.com</domain>
    <pin-set>
      <pin digest="SHA-256">AAAA...=</pin> <!-- pin primaire -->
      <pin digest="SHA-256">BBBB...=</pin> <!-- pin backup -->
    </pin-set>
  </domain-config>
  ```

### Jour 4 - Nettoyage securite restant

**S10 - Desactiver le reseau local en prod (iOS)**
- `ios/Runner/Info.plist` lignes 115-123
- Supprimer `NSAllowsLocalNetworking` ou le conditionner par build config

**S15 - Rate limiting cote client sur OTP**
- Ajouter un cooldown de 60s entre les requetes OTP :
  ```dart
  DateTime? _lastOtpRequest;
  bool get canRequestOtp =>
    _lastOtpRequest == null ||
    DateTime.now().difference(_lastOtpRequest!) > Duration(seconds: 60);
  ```

**S16 - Supprimer les URLs HTTP de dev du code**
- `lib/core/utils/constants.dart` lignes 15-16
- Deplacer dans --dart-define comme S2

**S17 - Activer l'obfuscation**
- `android/app/build.gradle.kts` :
  ```kotlin
  buildTypes {
    release {
      isMinifyEnabled = true
      isShrinkResources = true
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
  }
  ```
- Build Flutter avec obfuscation :
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/debug-info
  ```

---

## Phase 2 : Performance critique (2-3 jours)

### Jour 5 - Audio et animations

**P1 - Fixer le DuaPlayer (30 rebuilds/sec)**
- `lib/features/rituals/presentation/widgets/dua_player.dart` lignes 39-59
- Combiner les 3 streams en un seul :
  ```dart
  // Creer un state unifie
  class AudioState {
    final Duration position;
    final Duration duration;
    final bool isPlaying;
    const AudioState({this.position = Duration.zero, this.duration = Duration.zero, this.isPlaying = false});
  }

  // Un seul StreamBuilder
  StreamBuilder<AudioState>(
    stream: Rx.combineLatest3(
      _audioService.positionStream,
      _audioService.durationStream,
      _audioService.playerStateStream,
      (pos, dur, state) => AudioState(position: pos, duration: dur ?? Duration.zero, isPlaying: state.playing),
    ),
    builder: (context, snapshot) => _buildPlayer(snapshot.data ?? AudioState()),
  )
  ```

**P2 - Fixer la fuite memoire AnimationControllers**
- `lib/features/bot/presentation/pages/bot_chat_page.dart` lignes 21-29, 186-194
- Ne creer des controllers que pour les messages visibles :
  ```dart
  // Utiliser un cache LRU avec taille max
  final _controllerCache = LinkedHashMap<int, AnimationController>();
  static const _maxControllers = 20;

  AnimationController _getController(int index) {
    return _controllerCache.putIfAbsent(index, () {
      if (_controllerCache.length > _maxControllers) {
        _controllerCache.remove(_controllerCache.keys.first)?.dispose();
      }
      return AnimationController(vsync: this, duration: Duration(milliseconds: 300))..forward();
    });
  }
  ```

**P7 - Annuler les subscriptions audio avant recreation**
- `lib/core/services/audio_service.dart` lignes 52-84
  ```dart
  StreamSubscription? _positionSub, _durationSub, _stateSub;

  void _setupStreams() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _positionSub = positionStream.listen(...);
    // ...
  }
  ```

### Jour 6 - GPS et carte

**P5 - Cleanup du timer GPS**
- `lib/features/tracking/data/services/position_tracking_service.dart`
  ```dart
  @override
  void dispose() {
    stopTracking(); // Assure que le timer est annule
    super.dispose();
  }
  ```

**P4 - Optimiser les markers Google Maps**
- `lib/features/map/presentation/pages/google_map_page.dart` lignes 119-148
- Comparer l'ancien et le nouveau set, ne modifier que le delta :
  ```dart
  void _updateMarkers(List<Poi> pois) {
    final newMarkers = pois.map(_poiToMarker).toSet();
    if (!setEquals(_markers, newMarkers)) {
      setState(() => _markers = newMarkers);
    }
  }
  ```

**Q2 - Dispose des ressources Map**
- Meme fichier : ajouter un dispose propre
  ```dart
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
  ```

### Jour 7 - Chargements et listes

**P6 - Remplacer ListView par ListView.builder**
- `connectivity_esim_page.dart`
- `emergency_contacts_page.dart`
- `settings_screen.dart`

**P9 - Paralleliser les appels API de la HomePage**
  ```dart
  // Avant (sequentiel)
  final prayers = await getPrayers();
  final stats = await getStats();
  final alerts = await getAlerts();

  // Apres (parallele)
  final results = await Future.wait([getPrayers(), getStats(), getAlerts()]);
  ```

**P3 - Eviter les appels API redondants (Rituals)**
- Definir les providers au top-level avec keepAlive :
  ```dart
  final ritualsProvider = FutureProvider.autoDispose((ref) async {
    ref.keepAlive();
    return ref.read(ritualsRepositoryProvider).getRituals();
  });
  ```

---

## Phase 3 : Architecture et qualite (3-4 jours)

### Jour 8-9 - Clean Architecture

**Q3 - Refactorer RitualsPage**
- `lib/features/rituals/presentation/pages/rituals_page.dart` lignes 17-27
- Creer : `GetDuasUseCase` -> `DuasRepository` -> `DuasRemoteDataSource`
- La page ne doit connaitre que le UseCase via un provider Riverpod

**Q4 - Standardiser le state management**
- Choisir UN pattern et s'y tenir :
  - `StateNotifier` pour le state complexe (auth, bot)
  - `FutureProvider` pour les donnees read-only (rituels, duas, POIs)
  - Supprimer les inline providers ad-hoc

**Q5 - Unifier le systeme de cache**
- Definir des regles claires :
  - `FlutterSecureStorage` : tokens, PII (passeport, profil)
  - `Hive` : donnees structurees offline (rituels, duas, POIs)
  - Supprimer le `CacheService` SharedPreferences pour les donnees metier

### Jour 10-11 - Qualite restante

**Q6 - Gestion d'erreur user-friendly**
- Remplacer `e.toString()` par des messages traduits :
  ```dart
  String getUserMessage(Object error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout => l10n.errorTimeout,
        DioExceptionType.connectionError => l10n.errorNoConnection,
        _ => l10n.errorGeneric,
      };
    }
    return l10n.errorGeneric;
  }
  ```

**Q8 - Dispose des TextEditingControllers**
- `lib/features/health/presentation/pages/health_page.dart` ligne 524

**Q11 - Localiser les strings hardcodees**
- Rechercher toutes les strings FR dans le code et les deplacer dans les fichiers .arb

**S9 - Implementer le refresh token**
- Ajouter un intercepteur Dio qui refresh automatiquement :
  ```dart
  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        final newToken = await _authService.refreshToken();
        if (newToken != null) {
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          return handler.resolve(await dio.fetch(error.requestOptions));
        }
      }
      return handler.next(error);
    },
  ));
  ```

---

## Recapitulatif

| Phase | Duree | Issues corrigees | Priorite |
|-------|-------|-----------------|----------|
| 1 - Securite | 4 jours | S1-S4, S6-S8, S10, S15-S17, Q1 | CRITIQUE |
| 2 - Performance | 3 jours | P1-P7, P9, Q2 | HAUTE |
| 3 - Architecture | 4 jours | Q3-Q6, Q8, Q11, S9 | MOYENNE |
| **TOTAL** | **11 jours** | **33 issues** | |

Les 16 issues restantes (basses) peuvent etre traitees au fil du temps.
