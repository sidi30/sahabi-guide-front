import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';

/// Consentement explicite avant d'utiliser l'assistant IA.
/// Requis par App Store Review Guideline 5.1.1(i) + 5.1.2(i).
class AiConsentDialog {
  static const _consentKey = 'ai_assistant_consent_v1';

  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  static Future<void> setConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, value);
  }

  /// Retourne true si consentement donné (ou déjà donné auparavant).
  static Future<bool> ensureConsent(BuildContext context) async {
    if (await hasConsent()) return true;
    if (!context.mounted) return false;

    final l10n = AppLocalizations.of(context)!;
    final accepted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.smart_toy_outlined,
                    color: Theme.of(ctx).primaryColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.bot_consent_title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bot_consent_intro,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.bot_consent_data_sent,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(l10n.bot_consent_data_list),
                  const SizedBox(height: 4),
                  Text(
                    l10n.bot_consent_no_identity,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.bot_consent_third_party,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.bot_consent_third_party_desc,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.bot_consent_refuse_note,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.bot_consent_refuse,
                    style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.bot_consent_accept),
              ),
            ],
          ),
        ) ??
        false;

    await setConsent(accepted);
    return accepted;
  }
}
