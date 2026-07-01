import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Affiche la divulgation prominente de localisation requise par Google Play
/// AVANT de demander la permission OS.
/// Ne s'affiche qu'une seule fois (mémorisé en SharedPreferences).
class LocationDisclosureDialog {
  static const _shownKey = 'location_disclosure_shown';

  /// Vérifie si disclosure déjà affichée (permission déjà accordée ou refus définitif).
  static Future<bool> _shouldShow() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_shownKey) ?? false);
  }

  static Future<void> _markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shownKey, true);
  }

  /// Affiche la disclosure si nécessaire, puis demande la permission OS.
  /// Retourne true si permission accordée.
  static Future<bool> showAndRequest(BuildContext context) async {
    final permission = await Geolocator.checkPermission();

    // Permission déjà accordée
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    // Refus définitif — diriger vers paramètres
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await _showDeniedForeverDialog(context);
      }
      return false;
    }

    // Afficher disclosure avant la demande OS
    final shouldShow = await _shouldShow();
    if (shouldShow) {
      // Re-vérifier après l'await : le contexte peut avoir été démonté.
      if (!context.mounted) return false;
      final accepted = await _showDisclosure(context);
      // Ne marquer comme affichée que si l'utilisateur a accepté : un refus
      // doit réafficher la divulgation prominente la prochaine fois
      // (politique Google Play).
      if (!accepted) return false;
      await _markShown();
    }

    // Demander permission OS
    final result = await Geolocator.requestPermission();
    return result == LocationPermission.always ||
        result == LocationPermission.whileInUse;
  }

  static Future<bool> _showDisclosure(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.location_on,
                    color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Accès à votre localisation',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Format Google Play exact :
                // "[App] collecte [données] pour [fonctionnalité], [circonstances]."
                const Text(
                  'SahabiGuide collecte votre position GPS pour permettre :',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 10),
                _bullet(Icons.mosque, 'Votre guidage vers les lieux saints du Hajj'),
                _bullet(Icons.sos, 'La fonction SOS d\'urgence avec votre position exacte'),
                _bullet(Icons.group, 'Le regroupement avec votre caravane'),
                _bullet(Icons.access_time, 'Le calcul des heures de prière'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text(
                    'Cette collecte a lieu uniquement lorsque l\'application '
                    'est ouverte et active. Nous n\'accédons jamais à votre '
                    'position en arrière-plan.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openPrivacyPolicy(context),
                  child: Text(
                    'Voir la politique de confidentialité →',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continuer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<void> _showDeniedForeverDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Localisation bloquée'),
          ],
        ),
        content: const Text(
          'La permission de localisation a été refusée définitivement. '
          'Activez-la dans Paramètres > Applications > SahabiGuide > Autorisations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Ouvrir les paramètres'),
          ),
        ],
      ),
    );
  }

  static void _openPrivacyPolicy(BuildContext context) {
    // Ouvre la page privacy dans l'app
    Navigator.of(context).pushNamed('/settings/privacy');
  }

  static Widget _bullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
