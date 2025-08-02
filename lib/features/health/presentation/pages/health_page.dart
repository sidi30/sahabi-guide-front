import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _bloodTypeController.text = 'O+';
    _allergiesController.text = 'Aucune allergie connue';
    _medicationsController.text = 'Vitamine D, Oméga 3';
    _emergencyContactController.text = '+227 96 12 34 56 (Dr. Amadou)';
    _medicalNotesController.text = 'Suivi médical régulier. Dernière visite: 15/07/2024';
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _emergencyContactController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Santé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMedicalProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Overview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              color: AppTheme.secondaryColor,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profil Médical',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Informations médicales sécurisées',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Données chiffrées et sécurisées',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Medical Information Section
              Text(
                'Informations Médicales',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Blood Type
              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  hintText: 'Ex: O+, A-, B+, AB-',
                  prefixIcon: Icon(Icons.bloodtype),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Groupe sanguin requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Allergies
              TextFormField(
                controller: _allergiesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  hintText: 'Listez vos allergies connues',
                  prefixIcon: Icon(Icons.warning_amber),
                ),
              ),

              const SizedBox(height: 16),

              // Current Medications
              TextFormField(
                controller: _medicationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Médicaments actuels',
                  hintText: 'Listez vos médicaments en cours',
                  prefixIcon: Icon(Icons.medication),
                ),
              ),

              const SizedBox(height: 24),

              // Emergency Contact Section
              Text(
                'Contact d\'Urgence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emergencyContactController,
                decoration: const InputDecoration(
                  labelText: 'Contact d\'urgence',
                  hintText: 'Nom et numéro de téléphone',
                  prefixIcon: Icon(Icons.emergency),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact d\'urgence requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Medical Notes Section
              Text(
                'Notes Médicales',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _medicalNotesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes médicales',
                  hintText: 'Informations médicales importantes',
                  prefixIcon: Icon(Icons.note_alt),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Actions Rapides',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'QR Code Médical',
                      'Générer un QR code avec vos infos médicales',
                      Icons.qr_code,
                      AppTheme.primaryColor,
                      () => _generateMedicalQR(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Urgence',
                      'Appeler les services d\'urgence',
                      Icons.local_hospital,
                      AppTheme.accentColor,
                      () => _callEmergency(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveMedicalProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Sauvegarder le profil'),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.privacy_tip, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Confidentialité',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos informations médicales sont stockées de manière sécurisée et chiffrée sur votre appareil. Elles ne sont partagées qu\'en cas d\'urgence avec votre consentement.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMedicalProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to secure storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil médical sauvegardé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _generateMedicalQR() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Médical'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('QR Code Médical', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ce QR code contient vos informations médicales essentielles pour les urgences.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Share QR code
              Navigator.of(context).pop();
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _callEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appel d\'Urgence'),
        content: const Text(
          'Voulez-vous appeler les services d\'urgence ?\n\nNuméro: 15 (SAMU)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Make emergency call
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel d\'urgence en cours...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }
}
