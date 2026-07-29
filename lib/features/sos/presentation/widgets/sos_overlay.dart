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
    // LayoutBuilder, et NON MediaQuery : cette couche vit dans le `body` du
    // Scaffold, plus court que l'écran (AppBar + bottomNavigationBar en sont
    // retirés). Positionner le bouton d'après la hauteur de l'écran le plaçait
    // SOUS le bas du body — invisible. Un bouton d'urgence introuvable ne sert
    // à rien : la position se calcule sur la boîte réellement disponible.
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            const Positioned(top: 0, left: 0, right: 0, child: SosStatusBanner()),
            _DraggableSosButton(
              areaWidth: constraints.maxWidth,
              areaHeight: constraints.maxHeight,
            ),
          ],
        ),
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
  const _DraggableSosButton({required this.areaWidth, required this.areaHeight});

  /// Dimensions de la zone où le bouton peut vivre (le `body`, pas l'écran).
  final double areaWidth;
  final double areaHeight;

  @override
  ConsumerState<_DraggableSosButton> createState() => _DraggableSosButtonState();
}

class _DraggableSosButtonState extends ConsumerState<_DraggableSosButton> {
  static const _kLeft = 'sos_btn_left';
  static const _kTop = 'sos_btn_top';
  static const _kCollapsed = 'sos_btn_collapsed';

  /// Marge réservée au badge « × », qui déborde en haut à droite du bouton.
  static const double _badgeInset = 10;

  /// Estimation d'attente, remplacée par la mesure réelle dès le premier frame.
  /// La largeur dépend du libellé (« URGENCE », « GAGGAWA », arabe…), donc de
  /// la langue : la coder en dur laissait le bouton déborder de l'écran.
  static const Size _fallbackBox = Size(120, 80);

  final GlobalKey _boxKey = GlobalKey();
  Size? _measuredBox;

  /// Mesure le bouton après le rendu et rafraîchit les bornes si la taille a
  /// changé (première frame, changement de langue, texte plus long).
  void _measureAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = Size(
        box.size.width + _badgeInset,
        box.size.height + _badgeInset,
      );
      if (_measuredBox != size) setState(() => _measuredBox = size);
    });
  }

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
    final areaW = widget.areaWidth;
    final areaH = widget.areaHeight;

    // Bornes calculées sur la zone réelle. `max` protège les très petites
    // boîtes (tests, écrans courts) où la borne haute passerait sous la basse
    // et ferait lever une assertion à clamp().
    _measureAfterFrame();
    final box = _measuredBox ?? _fallbackBox;

    final maxLeft = (areaW - box.width - 8).clamp(8.0, double.infinity);
    final maxTop = (areaH - box.height - 8).clamp(8.0, double.infinity);

    // Défaut : bas-gauche de la zone, symétrique de l'assistant à droite.
    final left = (_left ?? 16).clamp(8.0, maxLeft);
    final top = (_top ?? (areaH - box.height - 16)).clamp(8.0, maxTop);

    if (_collapsed) {
      const handleW = 34.0;
      const handleH = 64.0;
      final maxHandleTop = (areaH - handleH - 8).clamp(8.0, double.infinity);
      return Positioned(
        left: 0,
        top: top.clamp(8.0, maxHandleTop),
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
      child: Padding(
        // Réserve la place du badge « × », qui déborde en haut à droite.
        padding: const EdgeInsets.only(top: _badgeInset, right: _badgeInset),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Enfant NON positionné : c'est lui qui dicte la taille du Stack,
            // donc la boîte mesurée. Le libellé change de largeur selon la
            // langue — la mesurer vaut mieux que la coder en dur.
            KeyedSubtree(
              key: _boxKey,
              child: GestureDetector(
                onPanStart: (_) => _dragging = true,
                onPanUpdate: (d) {
                  setState(() {
                    // Borné à la zone : on ne doit pas pouvoir pousser le
                    // bouton d'urgence hors de l'écran.
                    _left = (left + d.delta.dx).clamp(8.0, maxLeft);
                    _top = (top + d.delta.dy).clamp(8.0, maxTop);
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
              right: -_badgeInset,
              top: -_badgeInset,
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
