# 🔍 Page de Debug du Bot - Mode d'emploi

## 🎯 Objectif

La page de debug permet de tester **chaque service individuellement** pour identifier exactement où se trouve le problème.

---

## 🚀 Comment y accéder

### Méthode 1 : Via l'URL

1. Lance l'application
2. Dans la barre d'adresse du navigateur (pour web) ou via deep link, tape :
   ```
   /bot-debug
   ```

### Méthode 2 : Modification temporaire de la route

Dans `main.dart`, change temporairement la route initiale :

```dart
// Ligne 128 environ
initialLocation: AppRoutes.botDebug,  // Au lieu de AppRoutes.splash
```

Ensuite :
```bash
flutter run
```

### Méthode 3 : Ajouter un bouton dans HomePage

Temporairement, ajoute un bouton dans `home_page.dart` :

```dart
FloatingActionButton(
  onPressed: () => context.go('/bot-debug'),
  child: const Icon(Icons.bug_report),
)
```

---

## 🧪 Comment utiliser la page de debug

Une fois sur la page, tu verras 6 boutons de test :

### 1️⃣ Tester KnowledgeBase
Teste le chargement du fichier `hajj_knowledge_base.json`

**Ce qui est testé :**
- Le provider est chargé
- Le service s'initialise
- Les étapes du Hajj sont chargées depuis le JSON
- La première étape est accessible

**Erreurs possibles :**
- ❌ `Unable to load asset` → Le fichier JSON n'est pas dans `assets/data/`
- ❌ `FormatException` → Le JSON est malformé
- ❌ `No steps found` → Le JSON est vide ou mal structuré

---

### 2️⃣ Tester ContextService
Teste la détection GPS et la contextualisation

**Ce qui est testé :**
- Le provider est chargé
- Le contexte GPS est récupéré
- La localisation est détectée (ou non)
- Les duas sont suggérées

**Erreurs possibles :**
- ❌ `Permission denied` → Permissions GPS manquantes
- ❌ `Location service disabled` → GPS désactivé sur le device

---

### 3️⃣ Tester StorageService
Teste Hive et la persistance

**Ce qui est testé :**
- Le provider est chargé
- Hive s'initialise
- Les boxes sont créées
- Les statistiques sont accessibles

**Erreurs possibles :**
- ❌ `HiveError: Box already open` → Hive non fermé proprement
- ❌ `MissingPluginException` → Hive non initialisé dans main.dart
- ❌ `FileSystemException` → Problème de permissions de fichier

---

### 4️⃣ Tester NotificationService
Teste les notifications locales

**Ce qui est testé :**
- Le provider est chargé
- Le plugin de notifications s'initialise
- Les permissions sont demandées

**Erreurs possibles :**
- ❌ `MissingPluginException` → Plugin non configuré
- ❌ `Permission denied` → Permissions notifications refusées

---

### 5️⃣ Tester LLMService
Teste le service d'IA (optionnel)

**Ce qui est testé :**
- Le provider est chargé
- Le service s'initialise
- Les informations de configuration sont accessibles

**Erreurs possibles :**
- ❌ `DioError` → Problème de connexion (normal si pas d'Internet)

---

### 6️⃣ Tester BotService (COMPLET)
**ATTENTION** : Ce test fait tout en une fois

**Ce qui est testé :**
- Tous les services ci-dessus
- L'initialisation complète du bot
- Le démarrage de la conversation
- L'historique de messages

**Erreurs possibles :**
- ❌ Toute erreur des services ci-dessus
- ❌ `StateError` → État du bot invalide

---

## 📊 Interpréter les résultats

### ✅ Succès

```
[10:14:23] 🔍 Test KnowledgeBaseService...
[10:14:23] ✅ Provider chargé
[10:14:23] ✅ Initialisé
[10:14:23] ✅ 14 étapes chargées
[10:14:23] ✅ Première étape: Ihram
[10:14:23] 🎉 KnowledgeBase OK !
```

➡️ **Tout fonctionne !** Passe au test suivant.

---

### ❌ Échec

```
[10:14:23] 🔍 Test StorageService...
[10:14:23] ✅ Provider chargé
[10:14:24] ❌ ERREUR: MissingPluginException(No implementation found for method initFlutter on channel hive)
[10:14:24] Stack: ...
```

➡️ **Problème identifié !** Hive n'est pas initialisé dans `main.dart`.

**Solution** : Ajoute `await Hive.initFlutter();` dans `main()`.

---

## 🎯 Stratégie de debug

### Étape 1 : Teste les services un par un

1. Commence par **KnowledgeBase** (le plus simple)
2. Si ça marche, teste **ContextService**
3. Puis **StorageService**
4. Puis **NotificationService**
5. Puis **LLMService**

### Étape 2 : Identifie le premier échec

Dès qu'un test échoue, **STOP** et corrige ce problème avant de continuer.

### Étape 3 : Test complet

Une fois que les 5 premiers tests passent, lance le test **BotService complet**.

---

## 🔧 Corrections courantes

### Problème : KnowledgeBase échoue

```bash
# Vérifie que le fichier existe
ls sahabi-guide-front/assets/data/hajj_knowledge_base.json

# Vérifie que assets/data/ est dans pubspec.yaml
grep -A 5 "assets:" sahabi-guide-front/pubspec.yaml
```

**Solution** : Ajoute dans `pubspec.yaml` :
```yaml
flutter:
  assets:
    - assets/data/
```

---

### Problème : StorageService échoue

**Cause** : Hive non initialisé

**Solution** : Dans `main.dart`, ajoute :
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();  // ← ICI !
  // ...
}
```

---

### Problème : ContextService échoue

**Cause** : Permissions GPS

**Solution Android** : Dans `AndroidManifest.xml`, ajoute :
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Solution iOS** : Dans `Info.plist`, ajoute :
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous utilisons votre position pour vous guider pendant le Hajj</string>
```

---

### Problème : NotificationService échoue

**Cause** : Plugin non configuré ou permissions manquantes

**Solution Android** : Dans `AndroidManifest.xml`, ajoute :
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## 📸 Capture d'écran des résultats

Après avoir lancé les tests, **fais une capture d'écran des logs** et envoie-la moi. Je pourrai ainsi identifier exactement le problème.

---

## 🚀 Une fois tout testé

Si **TOUS** les tests passent (1 à 6), alors le bot devrait fonctionner correctement !

Retourne sur `/bot` et teste la conversation normale.

---

## 🔄 Revenir à la normale

N'oublie pas de **supprimer la route temporaire** ou de **retirer le bouton de debug** une fois le problème résolu !

---

**Bonne chance ! 🍀**

