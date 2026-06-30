import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Écran de choix du genre, affiché UNE FOIS au premier lancement (tant que
/// `pilgrim_gender` n'est pas défini). Indispensable : les rites diffèrent entre
/// un homme et une femme. Pilote aussi la palette par défaut + le badge.
class GenderSetupPage extends ConsumerStatefulWidget {
  const GenderSetupPage({super.key});

  @override
  ConsumerState<GenderSetupPage> createState() => _GenderSetupPageState();
}

class _GenderSetupPageState extends ConsumerState<GenderSetupPage> {
  String? _selected;

  Future<void> _confirm() async {
    if (_selected == null) return;
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pilgrim_gender', _selected!);
    await ref.read(settingsProvider.notifier).setGender(_selected!);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final color = ref.colors.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.menu_book_rounded, size: 56, color: color),
              const SizedBox(height: 20),
              Text(
                'Pour vous montrer les bons rites',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les rites du pèlerinage diffèrent entre un homme et une femme. '
                'Vous pourrez le modifier dans les Réglages.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ref.colors.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _card('MALE', Icons.man, 'Pèlerin', 'Homme')),
                  const SizedBox(width: 16),
                  Expanded(child: _card('FEMALE', Icons.woman, 'Pèlerine', 'Femme')),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected == null ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continuer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String value, IconData icon, String label, String subtitle) {
    final selected = _selected == value;
    final color = ref.colors.primary;
    final inactiveBg = ref.colors.surfaceVariant;
    final inactiveFg = ref.colors.textSecondary;
    return Semantics(
      label: '$label, $subtitle',
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.10) : inactiveBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: selected ? color : inactiveFg),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? color : inactiveFg,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected
                        ? color.withValues(alpha: 0.75)
                        : inactiveFg.withValues(alpha: 0.85),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
