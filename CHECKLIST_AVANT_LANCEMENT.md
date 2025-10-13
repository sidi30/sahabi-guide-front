# ✅ Checklist Avant Lancement

## 🔍 Vérifications Obligatoires

### 1. Configuration Flutter
- [ ] `flutter doctor` ne montre aucune erreur
- [ ] Toutes les dépendances sont installées (`flutter pub get`)
- [ ] Flutter version >= 3.10.0

### 2. Configuration Android
- [ ] Android SDK installé (API 35+)
- [ ] Android Studio configuré
- [ ] Émulateur créé OU téléphone connecté

### 3. Configuration Google Maps API
- [ ] ⚠️ **CRITIQUE** : Clé API Google Maps obtenue
- [ ] Clé API ajoutée dans `android/app/src/main/AndroidManifest.xml`
- [ ] Remplacer `YOUR_GOOGLE_MAPS_API_KEY_HERE` par votre vraie clé
- [ ] APIs activées dans Google Cloud Console :
  - [ ] Maps SDK for Android
  - [ ] (Optionnel) Places API
  - [ ] (Optionnel) Directions API

### 4. Backend API
- [ ] Le backend `sahabi-guide-api` est démarré
- [ ] L'API est accessible (tester avec Postman/curl)
- [ ] URL du backend configurée (si nécessaire)

### 5. Permissions
- [ ] Toutes les permissions sont dans AndroidManifest.xml ✅ (déjà fait)
  - Internet
  - Localisation (Fine, Coarse, Background)
  - Notifications
  - Alarmes exactes
  - Vibration

## 🚀 Commandes de Vérification

```bash
# 1. Vérifier Flutter
flutter doctor -v

# 2. Lister les devices disponibles
flutter devices

# 3. Nettoyer le projet (si nécessaire)
flutter clean
flutter pub get

# 4. Lancer l'application
flutter run

# 5. Lancer en mode release (plus rapide)
flutter run --release
```

## 📱 Devices Recommandés

### Émulateur Android (Android Studio)
- **Modèle** : Pixel 6, Pixel 7, ou similaire
- **API Level** : 33 (Android 13) ou supérieur
- **RAM** : 2048 MB minimum, 4096 MB recommandé
- **Espace disque** : 6 GB

### Téléphone Physique
- **Android** : 8.0 (API 26) ou supérieur
- **Débogage USB** : Activé
- **Connexion** : USB ou WiFi (ADB)

## ⚠️ Problèmes Connus et Solutions

### Google Maps ne s'affiche pas
**Cause** : Clé API manquante ou invalide
**Solution** : 
1. Vérifier dans `android/app/src/main/AndroidManifest.xml`
2. Ligne 21-23 doit contenir votre clé API
3. Relancer : `flutter clean && flutter run`

### "No devices found"
**Cause** : Aucun émulateur ou téléphone détecté
**Solution** :
1. Démarrer un émulateur dans Android Studio
2. OU connecter un téléphone avec débogage USB activé
3. Vérifier avec `flutter devices`

### Build Gradle Failed
**Cause** : Cache corrompu ou dépendances manquantes
**Solution** :
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Permission Denied
**Cause** : Permissions non acceptées
**Solution** :
1. Au premier lancement, accepter TOUTES les permissions
2. Si refusé, aller dans Paramètres > Apps > Sahabi Guide > Permissions

## 📝 Fichiers à Vérifier

### 1. `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Ligne 21-23 : Vérifier que la clé est présente -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIza...VOTRE_VRAIE_CLE"/>
```

### 2. `android/local.properties`
```properties
sdk.dir=C:\\Users\\VOTRE_USER\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\Program Files\\flutter
```

### 3. `lib/core/network/dio_client.dart` (optionnel)
Vérifier l'URL de base du backend si nécessaire

## ✅ Checklist Finale

**Avant de lancer `flutter run`, confirmez que :**

- [x] ✅ Toutes les permissions Android sont configurées
- [x] ✅ Le package Android est cohérent (`com.sahabi_guide.sahabi_guide`)
- [ ] ⚠️ La clé Google Maps API est configurée (À FAIRE)
- [ ] Flutter doctor ne montre aucune erreur
- [ ] Un device est disponible (émulateur ou téléphone)
- [ ] Les dépendances sont installées (`flutter pub get`)
- [ ] Le backend est accessible (optionnel pour le test initial)

## 🎯 Lancement

Une fois tout vérifié :

```bash
cd sahabi-guide-front
flutter run
```

**Si tout est correct, l'application devrait :**
1. Se compiler sans erreur
2. S'installer sur le device
3. Se lancer automatiquement
4. Afficher l'écran splash puis l'écran de choix d'authentification

**Au premier lancement, l'app demandera :**
- Permission de localisation → Accepter "Toujours autoriser"
- Permission de notifications → Accepter

## 📞 Que faire en cas de problème ?

1. **Lire les logs** : `flutter logs`
2. **Vérifier les erreurs** : Les messages d'erreur dans le terminal
3. **Nettoyer** : `flutter clean && flutter pub get`
4. **Consulter** : `INSTRUCTIONS_LANCEMENT.md` pour plus de détails
5. **Google Maps** : Voir `GOOGLE_MAPS_SETUP.md`

---

**Prêt ? Lancez `flutter run` ! 🚀**

