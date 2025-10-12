# Test : Gestion Passeport Non Enregistré

## 🎯 Objectif
Vérifier que l'application affiche un message d'erreur clair au lieu de la page de vérification OTP lorsqu'un numéro de passeport n'est pas enregistré.

## 📋 Scénario de test

### Cas 1 : Passeport non enregistré ❌

**Étapes :**
1. Ouvrir l'application
2. Cliquer sur "Se connecter avec passeport"
3. Entrer un numéro de passeport **non enregistré** (ex: `ZZ999999`)
4. Cliquer sur "Envoyer le code"

**Résultat attendu :**
- ❌ **NE PAS** afficher la page de vérification OTP
- ✅ Afficher une boîte de dialogue avec :
  - **Titre** : "Inscription requise"
  - **Message** : "Vous n'êtes pas inscrit. Rapprochez-vous de votre agence ou contactez-nous."
  - **Bouton** : "Compris"
- ✅ Rester sur la page de connexion après avoir fermé la boîte de dialogue

### Cas 2 : Passeport enregistré mais compte inactif ❌

**Étapes :**
1. Ouvrir l'application
2. Cliquer sur "Se connecter avec passeport"
3. Entrer un numéro de passeport d'un compte **désactivé**
4. Cliquer sur "Envoyer le code"

**Résultat attendu :**
- ❌ **NE PAS** afficher la page de vérification OTP
- ✅ Afficher une boîte de dialogue similaire au Cas 1

### Cas 3 : Passeport valide et actif ✅

**Données de test :**
- Passeport : `AB123456`
- Téléphone : `+33123456780`
- Statut : `CONFIRMED`

**Étapes :**
1. Ouvrir l'application
2. Cliquer sur "Se connecter avec passeport"
3. Entrer le numéro de passeport **AB123456**
4. Cliquer sur "Envoyer le code"

**Résultat attendu :**
- ✅ Afficher un snackbar de succès : "Code de vérification envoyé"
- ✅ **Rediriger** vers la page de vérification OTP (`/passport-otp`)
- ✅ Afficher le champ de saisie du code OTP à 6 chiffres

### Cas 4 : Rate limiting ⚠️

**Étapes :**
1. Faire plusieurs tentatives rapides (> 5) avec un passeport invalide
2. Essayer une nouvelle connexion

**Résultat attendu :**
- ⚠️ Afficher un snackbar d'avertissement : "Trop de tentatives de connexion. Veuillez réessayer plus tard."
- ❌ **NE PAS** afficher la page de vérification OTP

## 🔍 Points de contrôle technique

### Backend (`PassportAuthController.java`)
```java
if (result.getMessage().contains("non trouvé") || result.getMessage().contains("inactif")) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)  // 404
            .body(AuthResponse.error(result.getMessage()));
}
```

### Frontend (`passport_auth_remote_data_source.dart`)
```dart
on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    throw PassportNotFoundException(
      'Numéro de passeport non enregistré',
    );
  }
  // ...
}
```

### UI (`passport_login_page.dart`)
```dart
if (next.isPassportNotFound) {
  // Afficher dialogue d'erreur personnalisé
  NotificationService.showErrorDialog(
    context,
    title: 'Utilisateur non enregistré',
    message: '...',
  );
} else {
  // Afficher snackbar pour autres erreurs
  NotificationService.showError(context, next.errorMessage!);
}
```

## 📊 Résultats attendus

| Scénario | Page OTP affichée ? | Type de notification | Message |
|----------|---------------------|---------------------|---------|
| Passeport non enregistré | ❌ Non | Dialogue d'erreur | "Inscription requise" |
| Compte inactif | ❌ Non | Dialogue d'erreur | "Inscription requise" |
| Passeport valide | ✅ Oui | Snackbar succès | "Code de vérification envoyé" |
| Rate limit dépassé | ❌ Non | Snackbar warning | "Trop de tentatives..." |
| Erreur réseau | ❌ Non | Snackbar erreur | "Erreur de connexion..." |

## ✅ Validation

Pour valider que tout fonctionne correctement :

1. **Vérifier les logs backend** :
   ```
   WARN ... UserAuthService : Utilisateur pèlerin non trouvé ou inactif pour le passeport: AB****55
   ```

2. **Vérifier la réponse HTTP** :
   - Status : `404 NOT FOUND`
   - Body : 
     ```json
     {
       "success": false,
       "message": "Numéro de passeport non trouvé ou compte inactif",
       "token": null
     }
     ```

3. **Vérifier l'UI** :
   - Dialogue modal affiché
   - Titre et message corrects
   - Bouton "Compris" fonctionnel
   - Pas de navigation vers `/passport-otp`

## 🐛 Problèmes connus (résolus)

### ❌ Avant
- Le backend générait un OTP même pour les passeports non enregistrés
- Le frontend naviguait toujours vers la page OTP
- Message d'erreur affiché via snackbar générique

### ✅ Après
- ✅ Le backend retourne 404 sans générer d'OTP
- ✅ Le frontend détecte l'exception `PassportNotFoundException`
- ✅ Dialogue modal personnalisé avec message clair
- ✅ Pas de navigation vers la page OTP

## 📝 Notes

- Les données de test sont insérées via Liquibase (`002-seed-test-data.xml`)
- Les passeports valides pour les tests : `AB123456`, `CD789012`
- Les statuts actifs : `CONFIRMED`, `REGISTERED`, `IN_PROGRESS`
- Le rate limiting est configuré dans `application-dev.yml`

---

**Date de création** : 12 Octobre 2025  
**Auteur** : Sahabi Guide Team

