import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/models/emergency_contact_model.dart';

class AddEmergencyContactDialog extends StatefulWidget {
  final EmergencyContactModel? contact; // null pour création, non-null pour édition
  final Function(String name, String phone, String? relation, bool isPrimary) onSave;

  const AddEmergencyContactDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<AddEmergencyContactDialog> createState() => _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<AddEmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRelation;
  bool _isPrimary = false;

  final List<String> _relations = [
    'Époux/Épouse',
    'Père',
    'Mère',
    'Fils',
    'Fille',
    'Frère',
    'Sœur',
    'Ami(e)',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    
    // Si on édite un contact existant, pré-remplir les champs
    if (widget.contact != null) {
      final contact = widget.contact!;
      _nameController.text = contact.name;
      _phoneController.text = contact.phone;
      _selectedRelation = contact.relation;
      _isPrimary = contact.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Modifier le contact' : 'Ajouter un contact'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom complet
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '+33123456789',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le téléphone est obligatoire';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Relation
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                items: _relations.map((relation) => DropdownMenuItem(
                  value: relation,
                  child: Text(relation),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelation = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Contact principal
              CheckboxListTile(
                title: const Text('Contact principal'),
                subtitle: const Text('Ce contact sera appelé en premier en cas d\'urgence'),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedRelation,
        _isPrimary,
      );
      Navigator.pop(context);
    }
  }
}
