import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../auth/data/models/passport_auth_models.dart';
import '../../../auth/presentation/providers/passport_auth_provider.dart';

/// Écran d'édition du profil (self-service). Le pèlerin complète/modifie ses
/// informations lui-même après l'inscription : prénom, nom, genre, ville,
/// nationalité, date de naissance. Rien de sensible (passeport, agence...).
class EditProfilePage extends ConsumerStatefulWidget {
  final PilgrimProfile? initial;

  const EditProfilePage({super.key, this.initial});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _passport;
  late final TextEditingController _address;
  late final TextEditingController _emergency;
  late final TextEditingController _city;
  late final TextEditingController _nationality;
  String? _gender; // MALE | FEMALE | UNSPECIFIED
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _firstName = TextEditingController(text: p?.firstName ?? '');
    _lastName = TextEditingController(text: p?.lastName ?? '');
    _passport = TextEditingController(text: p?.passportNo ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _emergency = TextEditingController(text: p?.emergencyPhone ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _nationality = TextEditingController(text: p?.nationality ?? '');
    _gender = p?.gender;
    if (p?.dateOfBirth != null && p!.dateOfBirth!.isNotEmpty) {
      _dob = DateTime.tryParse(p.dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _passport.dispose();
    _address.dispose();
    _emergency.dispose();
    _city.dispose();
    _nationality.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'passportNo': _passport.text.trim(),
      'address': _address.text.trim(),
      'emergencyPhone': _emergency.text.trim(),
      'city': _city.text.trim(),
      'nationality': _nationality.text.trim(),
      if (_gender != null) 'gender': _gender,
      if (_dob != null)
        'dateOfBirth':
            '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
    };

    final ok = await ref.read(authNotifierProvider.notifier).updateProfile(data);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(authNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Mise à jour impossible'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Date de naissance',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Genre (personnalise les rites affichés).
                Text('Genre', style: TextStyle(fontWeight: FontWeight.w600, color: colors.textSecondary)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'MALE', label: Text('Homme'), icon: Icon(Icons.man)),
                    ButtonSegment(value: 'FEMALE', label: Text('Femme'), icon: Icon(Icons.woman)),
                    ButtonSegment(value: 'UNSPECIFIED', label: Text('Voir tout'), icon: Icon(Icons.visibility_outlined)),
                  ],
                  selected: {_gender ?? 'UNSPECIFIED'},
                  onSelectionChanged: (s) => setState(() => _gender = s.first),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passport,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de passeport (optionnel)',
                    prefixIcon: Icon(Icons.document_scanner_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergency,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Numéro d'urgence",
                    prefixIcon: Icon(Icons.emergency_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _city,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nationality,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nationalité',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _pickDob,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dob != null
                          ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'
                          : 'Non renseignée',
                      style: TextStyle(
                        color: _dob != null ? colors.textPrimary : colors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
