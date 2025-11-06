import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/models/emergency_contact_model.dart';
import '../providers/emergency_contacts_provider.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/add_emergency_contact_dialog.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emergencyContactsNotifierProvider.notifier).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(emergencyContactsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts d\'Urgence'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(emergencyContactsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: _buildBody(contactsState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(EmergencyContactsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(emergencyContactsNotifierProvider.notifier).clearError();
                ref.read(emergencyContactsNotifierProvider.notifier).loadContacts();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contact d\'urgence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez vos contacts d\'urgence pour votre sécurité',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddContactDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(emergencyContactsNotifierProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact primaire (en évidence)
          if (state.primaryContact != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Contact Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showEditContactDialog(state.primaryContact!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.primaryContact!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.primaryContact!.displayRelation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.primaryContact!.formattedPhone,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _callContact(state.primaryContact!.phone),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Appeler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Autres contacts
          if (state.secondaryContacts.isNotEmpty) ...[
            const Text(
              'Autres Contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],

          ...state.secondaryContacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EmergencyContactCard(
                  contact: contact,
                  onTap: () => _showContactActions(contact),
                  onCall: () => _callContact(contact.phone),
                  onEdit: () => _showEditContactDialog(contact),
                  onDelete: () => _showDeleteConfirmation(contact),
                ),
              )),

          // Bouton d'ajout si pas de contacts
          if (state.contacts.isEmpty)
            const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmergencyContactDialog(
        onSave: (name, phone, relation, isPrimary) {
          ref.read(emergencyContactsNotifierProvider.notifier).createContact(
            name: name,
            phone: phone,
            relation: relation,
            isPrimary: isPrimary,
          );
        },
      ),
    );
  }

  void _showEditContactDialog(EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AddEmergencyContactDialog(
        contact: contact,
        onSave: (name, phone, relation, isPrimary) {
          ref.read(emergencyContactsNotifierProvider.notifier).updateContact(
            contact.id,
            name: name,
            phone: phone,
            relation: relation,
            isPrimary: isPrimary,
          );
        },
      ),
    );
  }

  void _showContactActions(EmergencyContactModel contact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact.formattedPhone,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.primary),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.pop(context);
                _callContact(contact.phone);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.message, color: AppColors.accent),
              title: const Text('Envoyer un SMS'),
              onTap: () {
                Navigator.pop(context);
                _sendSms(contact.phone);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _showEditContactDialog(contact);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(contact);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callContact(String phone) async {
    try {
      await ref.read(emergencyContactsNotifierProvider.notifier).callContact(phone);
    } catch (e) {
      _showSnackBar('Erreur lors de l\'appel: $e', isError: true);
    }
  }

  Future<void> _sendSms(String phone) async {
    try {
      final uri = Uri.parse('sms:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Impossible d\'envoyer un SMS', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de l\'envoi SMS: $e', isError: true);
    }
  }

  void _showDeleteConfirmation(EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contact'),
        content: Text('Voulez-vous vraiment supprimer ${contact.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(emergencyContactsNotifierProvider.notifier).deleteContact(contact.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}









