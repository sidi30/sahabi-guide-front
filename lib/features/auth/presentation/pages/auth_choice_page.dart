import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/constants/app_colors.dart';

class AuthChoicePage extends ConsumerStatefulWidget {
  const AuthChoicePage({super.key});

  @override
  ConsumerState<AuthChoicePage> createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends ConsumerState<AuthChoicePage> {
  String _selectedRole = 'pilgrim'; // 'pilgrim' ou 'guide'
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _selectedRole);
    await prefs.setString('audio_language', _selectedLanguage);
    
    if (_selectedRole == 'pilgrim') {
      if (!mounted) return;
      context.push('/passport-login');
    } else {
      // Pour l'instant, les guides vont aussi vers le login passeport
      if (!mounted) return;
      context.push('/passport-login');
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sahabi Guide',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F5D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre guide pour un pèlerinage béni et harmonieux.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Je suis un...
              const Text(
                'Je suis un...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5F5D),
                ),
              ),
              const SizedBox(height: 16),

              // Options Pèlerin / Guide
              Row(
                children: [
                  Expanded(
                    child: _buildRoleOption(
                      icon: Icons.person,
                      label: 'Pèlerin',
                      value: 'pilgrim',
                      isSelected: _selectedRole == 'pilgrim',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleOption(
                      icon: Icons.groups,
                      label: 'Guide',
                      value: 'guide',
                      isSelected: _selectedRole == 'guide',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Langue
              const Text(
                'Langue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5F5D),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

              // Bouton Continuer sans connexion
              TextButton(
                onPressed: () async {
                  await _savePreferences();
                  if (!mounted) return;
                  context.go('/home');
                },
                child: const Text(
                  'Continuer sans connexion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5F4) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5F4) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
