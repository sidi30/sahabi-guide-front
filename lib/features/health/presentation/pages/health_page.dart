import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/health_profile_model.dart';
import '../providers/health_profile_provider.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedBloodGroup;

  String? _normalizeBloodType(String? s) {
    if (s == null) return null;
    const map = {
      'A_POSITIVITEIVE': BloodGroup.aPositive, // typo éventuelle
      'A+': BloodGroup.aPositive,
      'A-': BloodGroup.aNegative,
      'O+': BloodGroup.oPositive,
      'O-': BloodGroup.oNegative,
      'B+': BloodGroup.bPositive,
      'B-': BloodGroup.bNegative,
      'AB+': BloodGroup.abPositive,
      'AB-': BloodGroup.abNegative,
    };
    return map[s] ?? s;
  }
  final List<String> _allergies = [];
  final List<String> _conditions = [];
  final List<String> _treatments = [];

  @override
  void dispose() {
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthProfileAsync = ref.watch(healthProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Santé'),
        backgroundColor: ref.colors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMedicalProfile,
          ),
        ],
      ),
      body: healthProfileAsync.when(
        data: (profile) {
          // Charger les données du profil si disponible
          if (profile != null && _selectedBloodGroup == null) {
            _loadProfileData(profile);
          }
          return _buildContent(context, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(healthProfileNotifierProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadProfileData(HealthProfileModel profile) {
    _selectedBloodGroup = _normalizeBloodType(profile.bloodGroup);
    _allergies.clear();
    _allergies.addAll(profile.allergies);
    _conditions.clear();
    _conditions.addAll(profile.conditions);
    _treatments.clear();
    _treatments.addAll(profile.treatments);
    _emergencyContactController.text = profile.emergencyContact ?? '';
    _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
    _notesController.text = profile.notes ?? '';
  }

  Widget _buildContent(BuildContext context, HealthProfileModel? profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Overview Card
            _buildOverviewCard(context),

            const SizedBox(height: 24),

            // Blood Group Section
            Text(
              'Groupe Sanguin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _buildCurrentBloodValue(),
              decoration: const InputDecoration(
                labelText: 'Groupe sanguin',
                prefixIcon: Icon(Icons.bloodtype),
              ),
              items: BloodGroup.allGroups()
                  .map((group) => DropdownMenuItem<String>(
                        value: BloodGroup.fromFrench(group),
                        child: Text(group),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Groupe sanguin requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Allergies Section
            _buildListSection(
              context,
              'Allergies',
              _allergies,
              Icons.warning_amber,
              'Ajouter une allergie',
            ),

            const SizedBox(height: 24),

            // Conditions Section
            _buildListSection(
              context,
              'Conditions médicales',
              _conditions,
              Icons.medical_information,
              'Ajouter une condition',
            ),

            const SizedBox(height: 24),

            // Treatments Section
            _buildListSection(
              context,
              'Médicaments actuels',
              _treatments,
              Icons.medication,
              'Ajouter un médicament',
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
                labelText: 'Nom du contact',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact d\'urgence requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Numéro de téléphone requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Medical Notes
            Text(
              'Notes Médicales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes importantes',
                hintText: 'Informations médicales supplémentaires',
                prefixIcon: Icon(Icons.note_alt),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'QR Code',
                    'Partager',
                    Icons.qr_code,
                    ref.colors.primary,
                    () => _generateMedicalQR(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Urgence',
                    'Appeler',
                    Icons.local_hospital,
                    ref.colors.accent,
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.privacy_tip,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Confidentialité',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos informations médicales sont stockées de manière sécurisée et chiffrée. Elles ne sont partagées qu\'en cas d\'urgence avec votre consentement.',
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
    );
  }

  String? _buildCurrentBloodValue() {
    final values = BloodGroup.allGroups().map(BloodGroup.fromFrench).toSet();
    final normalized = _normalizeBloodType(_selectedBloodGroup);
    if (normalized == null) return null;
    return values.contains(normalized) ? normalized : null;
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Card(
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
                    color: ref.colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: ref.colors.secondary,
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
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Informations médicales sécurisées',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ref.colors.textSecondary,
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Données chiffrées et synchronisées',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
    String addButtonText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (items.isEmpty)
                  Center(
                    child: Text(
                      'Aucun élément ajouté',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ref.colors.textSecondary,
                          ),
                    ),
                  )
                else
                  ...items.map((item) => ListTile(
                        leading: Icon(icon, color: ref.colors.primary),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              items.remove(item);
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.zero,
                      )),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddItemDialog(context, title, items),
                    icon: const Icon(Icons.add),
                    label: Text(addButtonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  color: color.withValues(alpha: 0.1),
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
                      color: ref.colors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog(
      BuildContext context, String title, List<String> items) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter - $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Entrez une valeur',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  items.add(controller.text.trim());
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  Future<void> _saveMedicalProfile() async {
    if (_formKey.currentState!.validate()) {
      // Créer le profil à sauvegarder
      final profile = HealthProfileModel(
        bloodGroup: _selectedBloodGroup,
        allergies: _allergies,
        conditions: _conditions,
        treatments: _treatments,
        notes: _notesController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
      );

      // Sauvegarder via le provider
      final success = await ref
          .read(healthProfileNotifierProvider.notifier)
          .updateHealthProfile(profile);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil médical sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    Text('QR Code Médical',
                        style: TextStyle(color: Colors.grey)),
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
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri(scheme: 'tel', path: '15');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Impossible d\'appeler ce numéro')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ref.colors.accent),
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }
}
