import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/theme_extensions.dart';
import '../services/user_location_service.dart';
import 'location_disclosure_dialog.dart';

/// Feuille de choix de la position servant aux horaires de prière et aux
/// distances de la carte.
///
/// Deux modes :
/// - suivi GPS (avec bouton de mise à jour immédiate) ;
/// - lieu choisi manuellement, pour le pèlerin qui refuse la localisation,
///   n'a pas de signal (hôtel, sous-sol du Haram) ou prépare son voyage.
///
/// Renvoie `true` si la position effective a changé.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
    return changed ?? false;
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final UserLocationService _service = sl<UserLocationService>();
  bool _busy = false;
  String? _message;

  Future<void> _useGps() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    final granted = await LocationDisclosureDialog.showAndRequest(context);
    if (!granted) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'Localisation refusée. Choisissez un lieu ci-dessous.';
      });
      return;
    }

    final fix = await _service.refreshFromGps();
    if (!mounted) return;

    if (fix == null) {
      setState(() {
        _busy = false;
        _message = 'Position GPS introuvable. Réessayez à l\'extérieur, '
            'ou choisissez un lieu ci-dessous.';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _pick(HolyPlace place) async {
    await _service.setManualPlace(place);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final manual = _service.manualLocation;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ma position',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Sert au calcul des heures de prière et aux distances sur la carte.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 16),

            // Suivi GPS
            _OptionTile(
              icon: Icons.my_location,
              title: 'Utiliser ma position actuelle',
              subtitle: manual == null
                  ? 'Suivi GPS actif — appuyez pour actualiser'
                  : 'Repasser en suivi GPS automatique',
              selected: manual == null,
              trailing: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _busy ? null : _useGps,
            ),

            if (_message != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: context.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              'Ou choisir un lieu',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: UserLocationService.presets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final place = UserLocationService.presets[index];
                  final selected = manual != null &&
                      manual.latitude == place.latitude &&
                      manual.longitude == place.longitude;
                  return _OptionTile(
                    icon: Icons.place_outlined,
                    title: place.name,
                    subtitle: place.region,
                    selected: selected,
                    onTap: _busy ? null : () => _pick(place),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? context.primaryColor
                : context.textSecondaryColor.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? context.primaryColor.withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? context.primaryColor : context.textSecondaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && selected)
              Icon(Icons.check_circle, color: context.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
