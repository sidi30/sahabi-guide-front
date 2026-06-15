# Déploiement mobile — Sahabi Guide (Flutter)

> App **Flutter** (pas Expo/EAS — EAS ne build pas Flutter). iOS et Android se
> buildent **depuis git** sur des runners GitHub Actions, repo
> `sidi30/sahabi-guide-front`. Package iOS `com.sahabiguide.app`, package Android
> `com.sahabi_guide.sahabi_guide`.

Deux workflows (déclenchement manuel : Actions → Run workflow) :

| Workflow | Runner | Fait | Sortie |
|----------|--------|------|--------|
| `ios-testflight.yml` | macOS-15 + Xcode 26 | Flutter build → match (cert/profil) → archive → upload | TestFlight |
| `android-play.yml` | ubuntu + JDK 17 | Flutter build appbundle signé → (option) upload | `.aab` + Google Play |

---

## 1. Secrets GitHub (repo `sidi30/sahabi-guide-front`)

### iOS — TOUS POSÉS ✅
| Secret | Rôle | État |
|--------|------|------|
| `ASC_KEY_ID` | App Store Connect API key id (`87BWH7U7T2`, rôle App Manager) | ✅ |
| `ASC_ISSUER_ID` | Issuer id ASC (`c399cd9d-…`) | ✅ |
| `ASC_KEY_P8_BASE64` | `.p8` en base64, **format PKCS#8 brut** (ne PAS convertir en SEC1) | ✅ |
| `MATCH_GIT_URL` | repo certs chiffrés `git@github.com:sidi30/sahabi-certs.git` | ✅ |
| `MATCH_PASSWORD` | passphrase de déchiffrement match | ✅ |
| `MATCH_DEPLOY_KEY` | clé SSH **write** sur `sahabi-certs` | ✅ |

### Android — 3/4 POSÉS
| Secret | Rôle | État |
|--------|------|------|
| `ANDROID_KEYSTORE_BASE64` | `sahabi-release.jks` en base64 | ✅ |
| `ANDROID_KEY_PROPERTIES` | contenu de `android/key.properties` (alias `sahabi`, mots de passe) | ✅ |
| `GOOGLE_MAPS_API_KEY` | clé Maps (exigée par `android/app/build.gradle.kts:47`) | ✅ |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON du service account Google Play | ❌ **À FAIRE** |

---

## 2. Objets côté Apple (App Store Connect / Dev Portal) — TOUS CRÉÉS ✅
- **Clé API ASC** `87BWH7U7T2` (App Manager). *Les anciennes clés ne matchaient pas → 401.*
- **Bundle ID** `com.sahabiguide.app` (id `U5B9RZB5FA`). Créé via l'API ASC (`produce` ne marche pas en CI : login Apple ID + 2FA).
- **Fiche app** App Store Connect : id `6780557706` (créée à la main dans le web — l'API Apple ne crée pas d'app).
- **Cert distribution + provisioning profile** : générés par match, chiffrés dans `sahabi-certs`.
- `ITSAppUsesNonExemptEncryption = false` dans Info.plist → **pas de prompt Export Compliance**.

## 3. Objets côté Google Play — keystore OK, SA À FAIRE
- App `com.sahabi_guide.sahabi_guide` **déjà en prod** (versionCode le plus haut = **107**).
- **Keystore** `android/app/sahabi-release.jks` (alias `sahabi`) — la vraie clé release, sauvegardée en secret.
- **Service account** : ❌ inexistant sur cette machine. **À créer** (voir §5).

---

## 4. Fichiers locaux sensibles (cette machine, gitignored — NE JAMAIS committer)
| Fichier | Contenu |
|---------|---------|
| `C:\Users\ramzi\.certs\sahabi-asc.p8` | clé API ASC `87BWH7U7T2` (Apple n'autorise qu'1 téléchargement) |
| `android/app/sahabi-release.jks` | keystore release Android |
| `android/key.properties` | mots de passe keystore |
| `android/local.properties` | `googleMapsApiKey=…` |
| `play-service-account.json` | ❌ **manquant** — à créer (§5) |

Helpers (node, hand-rolled JWT ES256) : `~/.certs/asc-check.mjs`, `asc-create-bundle.mjs`, `asc-builds.mjs`, `asc-status.mjs`.

---

## 5. CE QU'IL RESTE À FAIRE (les 2 blocages)

### A. iOS — le build est uploadé mais pas visible sur TestFlight
Upload CI **réussi** (`Successfully uploaded package to App Store Connect`), mais
~2 h après, `0 build` / `0 preReleaseVersion` côté Apple → **échec de traitement
asynchrone**. Apple n'expose PAS le motif par l'API ; il est dans l'**email** envoyé à
`rsidiibrahim@gmail.com`. **Action :** ouvrir cet email, copier le motif → corriger
(souvent : icône manquante, binaire invalide, framework non signé). Re-déclencher ensuite.

### B. Android — créer le service account Google Play
1. **Play Console** → **Configuration / Setup** → **Accès API (API access)** → lier un projet Google Cloud.
2. **Créer un service account** → ouvre Google Cloud Console → **Create service account** (`sahabi-ci`).
3. Google Cloud → ce SA → **Keys → Add key → JSON** → télécharger → sauver `C:\Users\ramzi\.certs\sahabi-play-sa.json`.
4. Play Console → **Utilisateurs et autorisations** → **inviter** ce SA → droit **Release** (au moins track `internal`).
5. Donner le JSON → on pose le secret `PLAY_SERVICE_ACCOUNT_JSON`.

### C. versionCode Android
Play refuse un versionCode déjà uploadé. Prod = **107**. Pour chaque release Android :
soit bump `version:` dans `pubspec.yaml` (`1.2.1+108`), soit input `build_number=108` au lancement.

---

## 6. Procédure de release (une fois A+B réglés)

```bash
# iOS → TestFlight
gh workflow run ios-testflight.yml -R sidi30/sahabi-guide-front --ref main

# Android → Google Play (track internal), versionCode 108
gh workflow run android-play.yml -R sidi30/sahabi-guide-front --ref main \
  -f submit=true -f track=internal -f build_number=108
```

- **Gros changement** → bump `version:` dans `pubspec.yaml` (= versionName ET versionCode iOS/Android). C'est aussi le `runtimeVersion`.
- Auto-deploy : décommenter le bloc `push:` en tête de `ios-testflight.yml`.
- Flutter **épinglé 3.32.8** dans les 2 workflows (le canal `stable` dérive vers 3.44.x qui casse `google_fonts 6.3.0`). Ne pas dé-épingler sans tester.
- iOS : runner `macos-15` + sélection auto du **Xcode 26** (gate App Store « iOS 26 SDK »).
