import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/emergency_contact_model.dart';
import '../../data/services/emergency_contacts_service.dart';
import '../../../../core/di/injection_container.dart';

// Provider pour le service
final emergencyContactsServiceProvider = Provider<EmergencyContactsService>((ref) {
  return sl<EmergencyContactsService>();
});

// État des contacts d'urgence
class EmergencyContactsState {
  final List<EmergencyContactModel> contacts;
  final bool isLoading;
  final String? error;

  EmergencyContactsState({
    required this.contacts,
    required this.isLoading,
    this.error,
  });

  EmergencyContactsState.initial()
      : contacts = [],
        isLoading = false,
        error = null;

  EmergencyContactsState copyWith({
    List<EmergencyContactModel>? contacts,
    bool? isLoading,
    String? error,
  }) {
    return EmergencyContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  EmergencyContactModel? get primaryContact => 
      contacts.where((contact) => contact.isPrimary).isNotEmpty
          ? contacts.firstWhere((contact) => contact.isPrimary)
          : null;

  List<EmergencyContactModel> get secondaryContacts => 
      contacts.where((contact) => !contact.isPrimary).toList();
}

// Notifier pour les contacts d'urgence
class EmergencyContactsNotifier extends StateNotifier<EmergencyContactsState> {
  final EmergencyContactsService _service;

  EmergencyContactsNotifier(this._service) : super(EmergencyContactsState.initial());

  /// Charge tous les contacts d'urgence
  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final contacts = await _service.getEmergencyContacts();
      state = state.copyWith(
        contacts: contacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Crée un nouveau contact.
  ///
  /// Retourne `true` en cas de succès. En cas d'échec, on NE touche PAS à
  /// `state.error` (cela effacerait la liste affichée) : on relance l'exception
  /// pour que la page affiche un SnackBar tout en conservant la liste chargée.
  Future<bool> createContact({
    required String name,
    required String phone,
    String? relation,
    bool isPrimary = false,
  }) async {
    final newContact = await _service.createEmergencyContact(
      name: name,
      phone: phone,
      relation: relation,
      isPrimary: isPrimary,
    );

    final updatedContacts = [...state.contacts, newContact];
    state = state.copyWith(contacts: updatedContacts);
    return true;
  }

  /// Met à jour un contact. Voir [createContact] pour la gestion d'erreur.
  Future<bool> updateContact(
    String contactId, {
    required String name,
    required String phone,
    String? relation,
    bool isPrimary = false,
  }) async {
    final updatedContact = await _service.updateEmergencyContact(
      contactId,
      name: name,
      phone: phone,
      relation: relation,
      isPrimary: isPrimary,
    );

    final updatedContacts = state.contacts.map((contact) {
      return contact.id == contactId ? updatedContact : contact;
    }).toList();

    state = state.copyWith(contacts: updatedContacts);
    return true;
  }

  /// Supprime un contact. Voir [createContact] pour la gestion d'erreur.
  Future<bool> deleteContact(String contactId) async {
    await _service.deleteEmergencyContact(contactId);

    final updatedContacts = state.contacts
        .where((contact) => contact.id != contactId)
        .toList();

    state = state.copyWith(contacts: updatedContacts);
    return true;
  }

  /// Appelle un contact d'urgence
  Future<void> callContact(String phone) async {
    try {
      await _service.callEmergencyContact(phone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Actualise la liste
  Future<void> refresh() async {
    await loadContacts();
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider pour le notifier
final emergencyContactsNotifierProvider = 
    StateNotifierProvider<EmergencyContactsNotifier, EmergencyContactsState>((ref) {
  final service = ref.watch(emergencyContactsServiceProvider);
  return EmergencyContactsNotifier(service);
});

// Provider pour le contact primaire
final primaryEmergencyContactProvider = Provider<EmergencyContactModel?>((ref) {
  final contactsState = ref.watch(emergencyContactsNotifierProvider);
  return contactsState.primaryContact;
});













