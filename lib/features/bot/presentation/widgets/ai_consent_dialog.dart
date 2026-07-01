import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                const Expanded(
                  child: Text(
                    "Assistant IA du Hajj",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "L'assistant répond uniquement aux questions liées au "
                    "Hajj, à la Omra et à l'Islam. Les autres sujets sont "
                    "filtrés en amont.",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Text("Données envoyées à notre serveur :",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text("• Le texte de votre question\n"
                      "• La langue choisie (FR / EN / AR / HA)\n"
                      "• Les derniers messages de la conversation en cours"),
                  SizedBox(height: 4),
                  Text(
                    "Aucune donnée d'identité (nom, passeport, téléphone, "
                    "email, position GPS, santé) n'est envoyée.",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  Text("Traitement par un service IA tiers :",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                    "Pour générer la réponse, notre serveur transmet la "
                    "question, via une connexion chiffrée HTTPS, à "
                    "Google Gemini (Google LLC, USA). Google traite la "
                    "requête uniquement pour produire la réponse et ne la "
                    "conserve pas pour entraîner ses modèles "
                    "(engagement Google pour l'API Gemini).",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "En refusant, l'assistant fonctionnera en mode local "
                    "limité (réponses préchargées, sans IA).",
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Refuser',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("J'accepte"),
              ),
            ],
          ),
        ) ??
        false;

    await setConsent(accepted);
    return accepted;
  }
}
