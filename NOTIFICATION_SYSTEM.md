# Système de Notification Générique - Sahabi Guide

## 📌 Vue d'ensemble

Le système de notification générique permet d'afficher des messages utilisateur de manière cohérente et élégante à travers toute l'application.

## 🎯 Types de notifications

### 1. **Success** (Succès)
- Couleur : Vert (`AppColors.success`)
- Icône : `check_circle_outline`
- Usage : Confirmation d'actions réussies

### 2. **Error** (Erreur)
- Couleur : Rouge (`AppColors.error`)
- Icône : `error_outline`
- Usage : Erreurs critiques nécessitant l'attention de l'utilisateur

### 3. **Warning** (Avertissement)
- Couleur : Orange (`AppColors.warning`)
- Icône : `warning_amber_outlined`
- Usage : Avertissements ou actions nécessitant prudence

### 4. **Info** (Information)
- Couleur : Bleu (`AppColors.primary`)
- Icône : `info_outline`
- Usage : Informations générales

## 📦 Utilisation

### Import

```dart
import 'package:sahabi_guide/shared/widgets/notification_snackbar.dart';
```

### Méthodes rapides

#### Snackbars

```dart
// Succès
NotificationService.showSuccess(context, 'Opération réussie !');

// Erreur
NotificationService.showError(context, 'Une erreur est survenue');

// Avertissement
NotificationService.showWarning(context, 'Attention : action irréversible');

// Information
NotificationService.showInfo(context, 'Nouvelle fonctionnalité disponible');
```

#### Snackbar personnalisée

```dart
NotificationService.show(
  context,
  message: 'Message personnalisé',
  type: NotificationType.info,
  duration: Duration(seconds: 5),
  action: SnackBarAction(
    label: 'ANNULER',
    onPressed: () {
      // Action personnalisée
    },
  ),
);
```

### Boîtes de dialogue

#### Dialogue d'erreur

```dart
await NotificationService.showErrorDialog(
  context,
  title: 'Utilisateur non enregistré',
  message: 'Ce numéro de passeport n\'est pas enregistré dans notre système. Veuillez vous rapprocher de votre agence pour procéder à votre inscription.',
  actionText: 'Compris',
  onAction: () {
    // Action optionnelle après fermeture
  },
);
```

#### Dialogue d'information

```dart
await NotificationService.showInfoDialog(
  context,
  title: 'Nouvelle fonctionnalité',
  message: 'Découvrez notre nouvelle fonctionnalité de suivi GPS en temps réel !',
  actionText: 'En savoir plus',
  onAction: () {
    // Redirection vers la page d'information
  },
);
```

#### Dialogue de confirmation

```dart
final confirmed = await NotificationService.showConfirmDialog(
  context,
  title: 'Confirmation',
  message: 'Êtes-vous sûr de vouloir supprimer ce profil de santé ?',
  confirmText: 'Supprimer',
  cancelText: 'Annuler',
);

if (confirmed) {
  // Procéder à la suppression
}
```

## 🔧 Gestion des erreurs personnalisées

Le système intègre des exceptions personnalisées pour une meilleure gestion des erreurs d'authentification :

### Exceptions disponibles

1. **`PassportNotFoundException`**
   - Déclenchée quand un numéro de passeport n'est pas trouvé (404)
   - Affiche une boîte de dialogue spéciale invitant l'utilisateur à s'inscrire

2. **`PassportValidationException`**
   - Déclenchée quand la validation du passeport échoue (400)
   - Affiche un snackbar d'erreur

3. **`OtpInvalidException`**
   - Déclenchée quand le code OTP est invalide ou expiré

4. **`TokenInvalidException`**
   - Déclenchée quand le token JWT est invalide ou expiré

### Exemple d'utilisation

```dart
try {
  await authService.requestOtp(passportNo);
} on PassportNotFoundException catch (e) {
  // Cas spécial : passeport non enregistré
  NotificationService.showErrorDialog(
    context,
    title: 'Utilisateur non enregistré',
    message: e.message,
  );
} on PassportValidationException catch (e) {
  // Erreur de validation
  NotificationService.showError(context, e.message);
} catch (e) {
  // Erreur générique
  NotificationService.showError(context, 'Erreur inattendue: $e');
}
```

## 🎨 Personnalisation

### Durée d'affichage

Par défaut, les snackbars s'affichent pendant **4 secondes**. Vous pouvez personnaliser cette durée :

```dart
NotificationService.show(
  context,
  message: 'Message qui reste 10 secondes',
  type: NotificationType.info,
  duration: Duration(seconds: 10),
);
```

### Style

Les couleurs sont définies dans `AppColors` et peuvent être personnalisées globalement :

```dart
// Dans app_colors.dart
static const Color success = Color(0xFF4CAF50);
static const Color error = Color(0xFFD32F2F);
static const Color warning = Color(0xFFFF9800);
static const Color info = Color(0xFF2196F3);
```

## 📱 Accessibilité

- **Contraste élevé** : Les couleurs respectent les normes WCAG 2.1
- **Icônes claires** : Chaque type de notification a une icône distinctive
- **Lisibilité** : Police de taille 14px pour un confort de lecture optimal

## 🌍 Internationalisation

Les messages peuvent être traduits via le système i18n de l'application :

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

NotificationService.showSuccess(
  context,
  AppLocalizations.of(context)!.operationSuccessful,
);
```

## 📚 Bonnes pratiques

1. **Préférer les snackbars pour les feedbacks rapides**
   - Succès/échec d'une action
   - Messages d'information courts

2. **Utiliser les dialogues pour les informations critiques**
   - Erreurs nécessitant une action
   - Confirmations importantes
   - Messages d'inscription requis

3. **Éviter les notifications en cascade**
   - Une seule notification à la fois
   - Le système masque automatiquement la notification précédente

4. **Messages clairs et concis**
   - Maximum 2 lignes pour les snackbars
   - Pas de jargon technique pour l'utilisateur final

## 🚀 Exemples d'intégration

### Dans un formulaire de connexion

```dart
void _login() async {
  if (!_formKey.currentState!.validate()) {
    NotificationService.showWarning(
      context,
      'Veuillez remplir tous les champs',
    );
    return;
  }

  try {
    await authService.login(email, password);
    NotificationService.showSuccess(
      context,
      'Connexion réussie !',
    );
    context.go('/home');
  } on PassportNotFoundException catch (e) {
    await NotificationService.showErrorDialog(
      context,
      title: 'Compte introuvable',
      message: e.message,
      actionText: 'S\'inscrire',
      onAction: () => context.go('/register'),
    );
  } catch (e) {
    NotificationService.showError(
      context,
      'Erreur de connexion',
    );
  }
}
```

### Dans une page de paramètres

```dart
void _saveSettings() async {
  try {
    await settingsService.update(settings);
    NotificationService.showSuccess(
      context,
      'Paramètres enregistrés',
    );
  } catch (e) {
    NotificationService.showError(
      context,
      'Échec de l\'enregistrement',
    );
  }
}
```

---

**Créé pour Sahabi Guide** | Version 1.0 | Octobre 2025

