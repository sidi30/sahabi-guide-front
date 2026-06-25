import 'package:sahabi_guide/l10n/app_localizations.dart';

/// Identifiants STABLES (indépendants de la langue) pour les réponses rapides
/// (QCM) à VOCABULAIRE FIXE. On stocke ces clés dans `BotMessageModel.quickReplies`
/// au lieu du libellé FR brut, afin que :
///   1. le rendu affiche le libellé localisé (qui change avec la locale) ;
///   2. l'envoi de la réponse au backend/bot utilise toujours le libellé FR
///      canonique (le matching dans `BotService` est basé sur le FR).
///
/// Toutes les clés sont préfixées `qr:` pour les distinguer des réponses rapides
/// dynamiques (issues des données d'étape Hajj) qui, elles, ne sont pas dans cet
/// ensemble fixe et passent par le flux de traduction.
class QuickReplyKeys {
  static const String prefix = 'qr:';

  static const String otherQuestion = 'qr:other_question';
  static const String continue_ = 'qr:continue';
  static const String understood = 'qr:understood';
  static const String retry = 'qr:retry';
  static const String alhamdulillah = 'qr:alhamdulillah';
  static const String restart = 'qr:restart';

  static bool isKey(String value) => value.startsWith(prefix);

  /// Libellé FR CANONIQUE d'une clé fixe : c'est ce qui est envoyé à
  /// `BotService.handleAnswer` (dont la logique matche les chaînes FR).
  /// Renvoie `null` si la valeur n'est pas une clé fixe connue.
  static String? canonicalFr(String key) {
    switch (key) {
      case otherQuestion:
        return 'Autre question';
      case continue_:
        return 'Continuer';
      case understood:
        return 'Compris';
      case retry:
        return 'Réessayer';
      case alhamdulillah:
        return 'Alhamdulillah';
      case restart:
        return 'Recommencer';
      default:
        return null;
    }
  }

  /// Libellé LOCALISÉ affiché à l'utilisateur pour une clé fixe.
  /// Renvoie `null` si ce n'est pas une clé fixe connue (l'appelant affiche
  /// alors la valeur telle quelle — réponse rapide dynamique déjà localisée).
  static String? localizedLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case otherQuestion:
        return l10n.qr_other_question;
      case continue_:
        return l10n.qr_continue;
      case understood:
        return l10n.qr_understood;
      case retry:
        return l10n.qr_retry;
      case alhamdulillah:
        return l10n.qr_alhamdulillah;
      case restart:
        return l10n.qr_restart;
      default:
        return null;
    }
  }
}
