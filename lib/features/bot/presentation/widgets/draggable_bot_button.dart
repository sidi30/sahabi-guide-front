import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bouton flottant de l'assistant, DÉPLAÇABLE et RANGEABLE.
/// - Glisser pour le repositionner (position mémorisée).
/// - Appui long : le ranger en une petite poignée collée au bord (ne gêne plus).
/// - Appui sur la poignée : le ressortir.
/// - Appui simple : ouvrir l'assistant.
///
/// Doit être placé comme enfant direct d'un [Stack] (il renvoie un [Positioned]).
class DraggableBotButton extends StatefulWidget {
  const DraggableBotButton({super.key});

  @override
  State<DraggableBotButton> createState() => _DraggableBotButtonState();
}

class _DraggableBotButtonState extends State<DraggableBotButton> {
  static const _kLeft = 'bot_btn_left';
  static const _kTop = 'bot_btn_top';
  static const _kCollapsed = 'bot_btn_collapsed';
  static const double _size = 60;

  double? _left;
  double? _top;
  bool _collapsed = false;
  bool _loaded = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
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
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Position par défaut : en bas à droite (au-dessus de la barre de nav).
    double left = _left ?? (size.width - _size - 16);
    double top = _top ?? (size.height - _size - padding.bottom - 96);

    // Clamp dans l'écran.
    left = left.clamp(8.0, size.width - _size - 8);
    top = top.clamp(padding.top + 8, size.height - _size - padding.bottom - 8);

    if (_collapsed) {
      // Rangé : poignée VISIBLE collée au bord droit (chevron + robot) que l'on
      // touche pour ressortir l'assistant. Assez grande pour ne pas être ratée.
      const handleW = 40.0;
      const handleH = 68.0;
      return Positioned(
        right: 0,
        top: top.clamp(padding.top + 8, size.height - handleH - padding.bottom - 8),
        child: GestureDetector(
          onTap: () async {
            setState(() => _collapsed = false);
            await _persist();
          },
          child: Container(
            width: handleW,
            height: handleH,
            decoration: const BoxDecoration(
              color: Color(0xFF1D3557),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(34),
                bottomLeft: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D1D3557),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(-2, 3),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left, color: Colors.white70, size: 16),
                Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      // SizedBox un peu plus grand que le bouton pour loger le badge "×" masquer.
      child: SizedBox(
        width: _size + 10,
        height: _size + 10,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 10,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _left = (left + d.delta.dx);
                    _top = (top + d.delta.dy);
                  });
                },
                onPanEnd: (_) => _persist(),
                onLongPress: _collapse,
                onTap: () {
                  if (_navigating) return;
                  _navigating = true;
                  context.push('/bot').then((_) {
                    if (mounted) _navigating = false;
                  });
                },
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1D3557),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D3557).withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/bot.jpeg',
                      width: _size,
                      height: _size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Badge "×" pour masquer l'assistant (le ranger sur le bord).
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: _collapse,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF1D3557), width: 1),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 15, color: Color(0xFF1D3557)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Range l'assistant sur le bord droit (poignée). Réversible en touchant la poignée.
  Future<void> _collapse() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _collapsed = true);
    await _persist();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Assistant rangé. Touchez la poignée à droite pour le ressortir.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
