import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  String _name = 'Pèlerin';
  String _email = 'pelerin@example.com';
  String _phone = '';
  String _passportNumber = '';
  File? _profileImage;
  bool _isLoading = true;
  final bool _showQrCode = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    _name = await _storage.read(key: 'user_name') ?? 'Pèlerin';
    _email = await _storage.read(key: 'user_email') ?? 'pelerin@example.com';
    _phone = await _storage.read(key: 'user_phone') ?? '';
    _passportNumber = await _storage.read(key: 'passport_number') ?? '';

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.wait([
      _storage.write(key: 'user_name', value: _name),
      _storage.write(key: 'user_email', value: _email),
      _storage.write(key: 'user_phone', value: _phone),
      _storage.write(key: 'passport_number', value: _passportNumber),
    ]);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la sélection de l\'image')),
        );
      }
    }
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
              child: _profileImage == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A9D8F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 20),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3557),
          ),
        ),
        Text(
          _email,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactCard() {
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
            const Row(
              children: [
                Icon(Icons.contact_emergency, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Contact d\'Urgence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1D3557)),
              title: const Text('Contact Principal'),
              subtitle: const Text('+1 234 567 8900'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2A9D8F)),
                onPressed: () {
                  // TODO: Implémenter l'édition du contact
                  _showEditContactDialog();
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Ajouter un contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D3557),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // TODO: Implémenter l'ajout de contact
                  _showAddContactDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditContactDialog() {
    // TODO: Implémenter le dialogue d'édition de contact
  }

  void _showAddContactDialog() {
    // TODO: Implémenter le dialogue d'ajout de contact
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Profil'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1D3557)),
          bottom: const TabBar(
            labelColor: Color(0xFF1D3557),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4FC3F7),
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: 'Profil'),
              Tab(icon: Icon(Icons.emergency), text: 'Urgence'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Onglet Profil
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          TextFormField(
                            initialValue: _name,
                            decoration: const InputDecoration(
                              labelText: 'Nom Complet',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _name = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => _email = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!value.contains('@')) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _phone,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => _phone = value,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _passportNumber,
                            decoration: const InputDecoration(
                              labelText: 'Numéro de Passeport',
                              prefixIcon: Icon(Icons.credit_card_outlined),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _passportNumber = value,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A9D8F),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child:
                                  const Text('Enregistrer les modifications'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text('Déconnexion',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              // TODO: Implémenter la déconnexion
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Onglet Urgence
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildEmergencyContactCard(),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.medical_information,
                                        color: Color(0xFF1D3557)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Informations Médicales',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1D3557),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                ListTile(
                                  leading: const Icon(Icons.bloodtype,
                                      color: Colors.red),
                                  title: const Text('Groupe Sanguin'),
                                  subtitle: const Text(
                                      'A+'), // Récupérer du HealthScreen
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onPressed: () {
                                      // Naviguer vers HealthScreen
                                    },
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange),
                                  title: const Text('Allergies'),
                                  subtitle: const Text(
                                      'Aucune'), // Récupérer du HealthScreen
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onPressed: () {
                                      // Naviguer vers HealthScreen
                                    },
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.medication,
                                      color: Color(0xFF2A9D8F)),
                                  title: const Text('Médicaments'),
                                  subtitle: const Text(
                                      'Aucun'), // Récupérer du HealthScreen
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    onPressed: () {
                                      // Naviguer vers HealthScreen
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.emergency,
                              size: 20, color: Colors.red),
                          label: const Text('Mode Urgence',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            // TODO: Activer le mode urgence
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Mode Urgence'),
                                content: const Text(
                                    'Voulez-vous activer le mode urgence ? Cela enverra votre position et vos informations médicales aux secours.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Activer le mode urgence
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Mode urgence activé - Les secours ont été alertés'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    child: const Text('Activer',
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
                ],
              ),
      ),
    );
  }
}
