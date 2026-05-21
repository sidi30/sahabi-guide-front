import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

class AuthChoicePage extends ConsumerStatefulWidget {
  const AuthChoicePage({super.key});

  @override
  ConsumerState<AuthChoicePage> createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends ConsumerState<AuthChoicePage> {
  String _selectedRole = 'pilgrim'; // 'pilgrim' ou 'visitor'
  String _selectedLanguage = 'hausa'; // 'hausa' ou 'djerma'

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRole = prefs.getString('user_role') ?? 'pilgrim';
      _selectedLanguage = prefs.getString('audio_language') ?? 'hausa';
    });
  }

  Future<void> _saveAndContinue() async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole);
    await prefs.setString('audio_language', _selectedLanguage);

    if (_selectedRole == 'pilgrim') {
      // Les pèlerins vont vers la connexion par passeport
      if (!mounted) return;
      context.push('/passport-login');
    } else {
      // Les visiteurs vont vers l'inscription newsletter
      if (!mounted) return;
      context.push('/visitor-registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo et titre
              Center(
                child: Column(
                  children: [
                    Semantics(
                      label: AppLocalizations.of(context)!.accessibility_logo,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/favicon/web-app-manifest-logo-192x192.png', // Logo pin
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback avec apple-touch-icon
                            return Image.asset(
                              'assets/favicon/apple-touch-icon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error2, stackTrace2) {
                                return Icon(
                                  Icons.location_on,
                                  color: ref.colors.primary,
                                  size: 50,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ref.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.splash_welcome,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: ref.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Je suis un...
              Text(
                'Je suis un...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ref.colors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Options Pèlerin / Visiteur
              Row(
                children: [
                  Expanded(
                    child: _buildRoleOption(
                      icon: Icons.person,
                      label: 'Pèlerin',
                      subtitle: 'Avec passeport',
                      value: 'pilgrim',
                      isSelected: _selectedRole == 'pilgrim',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleOption(
                      icon: Icons.explore_outlined,
                      label: 'Visiteur',
                      subtitle: 'Juste explorer',
                      value: 'visitor',
                      isSelected: _selectedRole == 'visitor',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Langue
              Text(
                'Langue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ref.colors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Options Hausa / Djerma
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      icon: Icons.volume_up,
                      label: 'Hausa',
                      value: 'hausa',
                      isSelected: _selectedLanguage == 'hausa',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLanguageOption(
                      icon: Icons.volume_up,
                      label: 'Djerma',
                      value: 'djerma',
                      isSelected: _selectedLanguage == 'djerma',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Bouton Continuer
              ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ref.colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton Continuer sans connexion (acces libre lecture seule)
              // Donne acces aux pages publiques : Rituels, Douas, Carte+POI, IA.
              // Les autres pages (Accueil, Videos, Profil) restent fermees.
              TextButton(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await _savePreferences();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_visitor', true);
                  if (!context.mounted) return;
                  context.go('/rituals');
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'Continuer sans connexion (accès libre)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ref.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole);
    await prefs.setString('audio_language', _selectedLanguage);
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required String value,
    required bool isSelected,
  }) {
    final inactiveBg = ref.colors.surfaceVariant;
    final inactiveFg = ref.colors.textSecondary;
    return Semantics(
      label: subtitle != null ? '$label, $subtitle' : label,
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedRole = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: isSelected
                  ? ref.colors.primary.withValues(alpha: 0.1)
                  : inactiveBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? ref.colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isSelected ? ref.colors.primary : inactiveFg,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? ref.colors.primary : inactiveFg,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? ref.colors.primary.withValues(alpha: 0.75)
                          : inactiveFg.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
  }) {
    final inactiveBg = ref.colors.surfaceVariant;
    final inactiveFg = ref.colors.textSecondary;
    return Semantics(
      label: 'Langue $label',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedLanguage = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: isSelected
                  ? ref.colors.primary.withValues(alpha: 0.1)
                  : inactiveBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? ref.colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? ref.colors.primary : inactiveFg,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? ref.colors.primary : inactiveFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
