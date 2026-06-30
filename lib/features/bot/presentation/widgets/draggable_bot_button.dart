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
      // Rangé : petite poignée semi-transparente collée au bord droit.
      const handleW = 22.0;
      return Positioned(
        right: 0,
        top: top.clamp(padding.top + 8, size.height - 56 - padding.bottom - 8),
        child: GestureDetector(
          onTap: () async {
            setState(() => _collapsed = false);
            await _persist();
          },
          child: Container(
            width: handleW,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF1D3557),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _left = (left + d.delta.dx);
            _top = (top + d.delta.dy);
          });
        },
        onPanEnd: (_) => _persist(),
        onLongPress: () async {
          // Ranger sur le bord.
          final messenger = ScaffoldMessenger.of(context);
          setState(() => _collapsed = true);
          await _persist();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Assistant rangé. Touchez la poignée pour le ressortir.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
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
    );
  }
}
