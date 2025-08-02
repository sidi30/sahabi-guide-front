import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HajjOnboardingPage extends StatefulWidget {
  const HajjOnboardingPage({super.key});

  @override
  State<HajjOnboardingPage> createState() => _HajjOnboardingPageState();
}

class _HajjOnboardingPageState extends State<HajjOnboardingPage> {
  String selectedRole = '';
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A9D8F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Hajj Companion',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3557),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Your guide for a blessed and seamless\npilgrimage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Role Selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'I am a...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Pilgrim Button
              _buildRoleButton(
                icon: Icons.person,
                title: 'Pilgrim',
                isSelected: selectedRole == 'pilgrim',
                onTap: () => setState(() => selectedRole = 'pilgrim'),
              ),
              
              const SizedBox(height: 12),
              
              // Guide Button
              _buildRoleButton(
                icon: Icons.people,
                title: 'Guide',
                isSelected: selectedRole == 'guide',
                onTap: () => setState(() => selectedRole = 'guide'),
              ),
              
              const SizedBox(height: 40),
              
              // Language Selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Language Buttons Row
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      icon: Icons.volume_up,
                      title: 'Hausa',
                      isSelected: selectedLanguage == 'hausa',
                      onTap: () => setState(() => selectedLanguage = 'hausa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLanguageButton(
                      icon: Icons.volume_up,
                      title: 'Djerma',
                      isSelected: selectedLanguage == 'djerma',
                      onTap: () => setState(() => selectedLanguage = 'djerma'),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole.isNotEmpty && selectedLanguage.isNotEmpty
                      ? () => context.go('/menu')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
