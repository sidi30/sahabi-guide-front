import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bouton flottant animé du bot Hajj
/// Accessible partout dans l'app
class FloatingBotButton extends ConsumerStatefulWidget {
  const FloatingBotButton({super.key});

  @override
  ConsumerState<FloatingBotButton> createState() => _FloatingBotButtonState();
}

class _FloatingBotButtonState extends ConsumerState<FloatingBotButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de pulsation légère (3 secondes)
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openBot() {
    context.push('/bot');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D3557).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _openBot,
              backgroundColor: const Color(0xFF1D3557),
              elevation: 6,
              heroTag: 'bot_button',
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bot.jpeg',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Variante compacte (icône seulement)
class CompactFloatingBotButton extends ConsumerStatefulWidget {
  const CompactFloatingBotButton({super.key});

  @override
  ConsumerState<CompactFloatingBotButton> createState() =>
      _CompactFloatingBotButtonState();
}

class _CompactFloatingBotButtonState extends ConsumerState<CompactFloatingBotButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06D6A0).withValues(alpha: 0.4),
                blurRadius: 10 + (8 * _controller.value),
                spreadRadius: 1 + (2 * _controller.value),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/bot'),
            backgroundColor: const Color(0xFF06D6A0),
            elevation: 4,
            heroTag: 'bot_button_compact',
            child: const Icon(
              Icons.chat_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}


