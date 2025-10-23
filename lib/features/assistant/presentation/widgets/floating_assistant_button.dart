import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/assistant_chat_page.dart';

/// Bouton flottant animé de l'assistant
/// Toujours visible sur toutes les pages
/// Animation de rotation et effet "respiration"
class FloatingAssistantButton extends ConsumerStatefulWidget {
  const FloatingAssistantButton({super.key});

  @override
  ConsumerState<FloatingAssistantButton> createState() => _FloatingAssistantButtonState();
}

class _FloatingAssistantButtonState extends ConsumerState<FloatingAssistantButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de rotation continue (6 secondes par tour)
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Animation d'effet "respiration" (scale)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAssistant() {
    // Option 1 : Navigation avec go_router
    context.push('/assistant');
    
    // Option 2 : Ouvrir en modal (commenté pour l'instant)
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => DraggableScrollableSheet(
    //     initialChildSize: 0.9,
    //     minChildSize: 0.5,
    //     maxChildSize: 0.95,
    //     builder: (_, controller) => Container(
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).scaffoldBackgroundColor,
    //         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    //       ),
    //       child: const AssistantChatPage(),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Animation discrète : seulement pulsation légère (1.0 → 1.05 → 1.0)
        final discreteScale = 1.0 + (_scaleAnimation.value - 1.0) * 0.3;
        
        return Transform.scale(
          scale: discreteScale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Ombre subtile
                BoxShadow(
                  color: const Color(0xFF1D3557).withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _openAssistant,
              backgroundColor: const Color(0xFF1D3557),
              elevation: 4,
              heroTag: 'assistant_button',
              child: const Icon(
                Icons.smart_toy, // Icône bot seulement
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Variante : Bouton circulaire simple (plus discret)
class CompactFloatingAssistantButton extends ConsumerStatefulWidget {
  const CompactFloatingAssistantButton({super.key});

  @override
  ConsumerState<CompactFloatingAssistantButton> createState() =>
      _CompactFloatingAssistantButtonState();
}

class _CompactFloatingAssistantButtonState
    extends ConsumerState<CompactFloatingAssistantButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
                color: const Color(0xFF06D6A0).withOpacity(0.4),
                blurRadius: 10 + (10 * _controller.value),
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/assistant'),
            backgroundColor: const Color(0xFF06D6A0),
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

