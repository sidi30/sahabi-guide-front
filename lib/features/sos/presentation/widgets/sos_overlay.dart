import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import 'sos_button.dart';
import 'sos_status_banner.dart';

/// Couche SOS des écrans principaux : le bouton d'appel au secours et le
/// bandeau d'état du dernier envoi.
///
/// À placer comme enfant direct d'un [Stack] occupant le corps de l'écran
/// (elle renvoie un [Positioned]). Les zones vides ne captent pas les touchers :
/// le contenu dessous (carte, listes) reste utilisable.
class SosOverlay extends StatelessWidget {
  const SosOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: SosStatusBanner()),
          _DraggableSosButton(),
        ],
      ),
    );
  }
}

/// Bouton SOS DÉPLAÇABLE et RANGEABLE, calqué sur `DraggableBotButton` pour que
/// les deux boutons flottants se manipulent de la même façon.
///
/// - Glisser : le repositionner (position mémorisée).
/// - Appui long (ou badge « × ») : le ranger en poignée collée au bord gauche.
/// - Appui simple : déclencher le compte à rebours SOS.
///
/// DIFFÉRENCE VOLONTAIRE avec l'assistant : une fois rangé, l'assistant demande
/// un toucher pour ressortir PUIS un autre pour l'ouvrir. Ici, **un seul appui
/// sur la poignée déclenche le SOS**, rangé ou non. Demander deux gestes à
/// quelqu'un en détresse annulerait l'intérêt du bouton. Pour ressortir le
/// bouton complet sans alerter : appui long sur la poignée.
class _DraggableSosButton extends ConsumerStatefulWidget {
  const _DraggableSosButton();

  @override
  ConsumerState<_DraggableSosButton> createState() => _DraggableSosButtonState();
}

class _DraggableSosButtonState extends ConsumerState<_DraggableSosButton> {
  static const _kLeft = 'sos_btn_left';
  static const _kTop = 'sos_btn_top';
  static const _kCollapsed = 'sos_btn_collapsed';

  /// Encombrement du bouton déployé (cohérent avec les contraintes minimales de
  /// [SosFloatingButton] : 72 x 56, plus la marge du badge « × »).
  static const double _width = 76;
  static const double _height = 58;

  double? _left;
  double? _top;
  bool _collapsed = false;
  bool _loaded = false;

  /// Vrai pendant un glissement : empêche le `onTap` de fin de geste de
  /// déclencher un SOS alors que le pèlerin voulait seulement déplacer le
  /// bouton.
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _left = prefs.getDouble(_kLeft);
      _top = prefs.getDouble(_kTop);
      _collapsed = prefs.getBool(_kCollapsed) ?? false;
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (_left != null) await prefs.setDouble(_kLeft, _left!);
    if (_top != null) await prefs.setDouble(_kTop, _top!);
    await prefs.setBool(_kCollapsed, _collapsed);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final t = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Défaut : bas-gauche, au-dessus de la barre de navigation, symétrique de
    // l'assistant qui se range à droite.
    double left = _left ?? 16;
    double top = _top ?? (size.height - _height - padding.bottom - 96);

    left = left.clamp(8.0, size.width - _width - 8);
    top = top.clamp(padding.top + 8, size.height - _height - padding.bottom - 8);

    if (_collapsed) {
      const handleW = 34.0;
      const handleH = 64.0;
      return Positioned(
        left: 0,
        top: top.clamp(padding.top + 8, size.height - handleH - padding.bottom - 8),
        child: Semantics(
          button: true,
          label: t.sos_button_semantics,
          child: GestureDetector(
            // Un seul geste, même rangé : c'est un appel au secours.
            onTap: () => startSosCountdown(context, ref),
            // Ressortir le bouton complet sans déclencher d'alerte.
            onLongPress: () async {
              setState(() => _collapsed = false);
              await _persist();
            },
            child: Container(
              width: handleW,
              height: handleH,
              decoration: const BoxDecoration(
                color: kSosRed,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4DB3261E),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.sos_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: _width + 10,
        height: _height + 10,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 10,
              child: GestureDetector(
                onPanStart: (_) => _dragging = true,
                onPanUpdate: (d) {
                  setState(() {
                    _left = left + d.delta.dx;
                    _top = top + d.delta.dy;
                  });
                },
                onPanEnd: (_) {
                  _dragging = false;
                  _persist();
                },
                onLongPress: _collapse,
                child: IgnorePointer(
                  // Le bouton gère son propre `onTap` ; on l'ignore pendant un
                  // glissement pour ne pas déclencher un SOS involontaire.
                  ignoring: _dragging,
                  child: const SosFloatingButton(compact: true),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Semantics(
                button: true,
                label: t.sos_collapse_semantics,
                child: GestureDetector(
                  onTap: _collapse,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: kSosRed, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, size: 15, color: kSosRed),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Range le bouton sur le bord gauche. Le message rappelle qu'il reste
  /// utilisable en un seul appui — sans quoi le pèlerin pourrait croire qu'il
  /// vient de désactiver son SOS.
  Future<void> _collapse() async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context)!;
    setState(() => _collapsed = true);
    await _persist();
    messenger.showSnackBar(
      SnackBar(
        content: Text(t.sos_collapsed_hint),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
