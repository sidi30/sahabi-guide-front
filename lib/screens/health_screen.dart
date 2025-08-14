import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  String _bloodType = '';
  String _allergies = '';
  String _medications = '';
  String _conditions = '';
  String _emergencyContact = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);

    _bloodType = await _storage.read(key: 'blood_type') ?? '';
    _allergies = await _storage.read(key: 'allergies') ?? '';
    _medications = await _storage.read(key: 'medications') ?? '';
    _conditions = await _storage.read(key: 'conditions') ?? '';
    _emergencyContact = await _storage.read(key: 'emergency_contact') ?? '';

    setState(() => _isLoading = false);
  }

  Future<void> _saveHealthData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.wait([
      _storage.write(key: 'blood_type', value: _bloodType),
      _storage.write(key: 'allergies', value: _allergies),
      _storage.write(key: 'medications', value: _medications),
      _storage.write(key: 'conditions', value: _conditions),
      _storage.write(key: 'emergency_contact', value: _emergencyContact),
    ]);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations de santé mises à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil Santé'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D3557)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveHealthData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(
                      title: 'Groupe Sanguin',
                      icon: Icons.bloodtype,
                      child: DropdownButtonFormField<String>(
                        value: _bloodType.isEmpty ? null : _bloodType,
                        decoration: const InputDecoration(
                          labelText: 'Sélectionnez votre groupe sanguin',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'A+',
                          'A-',
                          'B+',
                          'B-',
                          'AB+',
                          'AB-',
                          'O+',
                          'O-'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _bloodType = value ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Allergies',
                      icon: Icons.warning_amber_rounded,
                      child: TextFormField(
                        initialValue: _allergies,
                        decoration: const InputDecoration(
                          labelText: 'Listez vos allergies',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _allergies = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Médicaments',
                      icon: Icons.medication,
                      child: TextFormField(
                        initialValue: _medications,
                        decoration: const InputDecoration(
                          labelText: 'Médicaments actuels',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _medications = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Conditions Médicales',
                      icon: Icons.medical_services,
                      child: TextFormField(
                        initialValue: _conditions,
                        decoration: const InputDecoration(
                          labelText: 'Conditions médicales existantes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _conditions = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Contact d\'Urgence',
                      icon: Icons.contact_emergency,
                      child: TextFormField(
                        initialValue: _emergencyContact,
                        decoration: const InputDecoration(
                          labelText: 'Nom et numéro de téléphone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => _emergencyContact = value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.medical_services_outlined),
                      label: const Text('Générer QR Code Santé'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A9D8F),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        // TODO: Implémenter la génération du QR Code
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Génération du QR Code...')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.emergency),
                      label: const Text('Mode Urgence'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        // TODO: Implémenter le mode urgence
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Mode Urgence'),
                            content:
                                const Text('Voulez-vous appeler les secours ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Appeler les secours
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Appel d\'urgence effectué'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                                child: const Text('Appeler',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1D3557)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
