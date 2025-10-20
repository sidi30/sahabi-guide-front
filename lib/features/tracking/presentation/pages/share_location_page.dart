import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/services/location_sharing_service.dart';
import '../../data/models/sharing_link_model.dart';
import 'package:share_plus/share_plus.dart';

/// Page pour partager sa localisation avec la famille
class ShareLocationPage extends StatefulWidget {
  const ShareLocationPage({super.key});

  @override
  State<ShareLocationPage> createState() => _ShareLocationPageState();
}

class _ShareLocationPageState extends State<ShareLocationPage> {
  final LocationSharingService _sharingService = LocationSharingService(
    dioClient: sl(),
  );
  final FlutterSecureStorage _secureStorage = sl<FlutterSecureStorage>();

  List<SharingLinkModel> _activeLinks = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _selectedDuration = 30; // jours

  @override
  void initState() {
    super.initState();
    _loadActiveLinks();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveLinks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null) {
        throw Exception('Non connecté');
      }

      final links = await _sharingService.getActiveLinks(userId);
      setState(() {
        _activeLinks = links;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewLink() async {
    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) {
      _showSnackBar('Non connecté', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final link = await _sharingService.createSharingLink(
        userId: userId,
        expiresInDays: _selectedDuration,
        familyMemberName: _familyNameController.text.trim().isNotEmpty
            ? _familyNameController.text.trim()
            : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      _familyNameController.clear();
      _descriptionController.clear();

      _showSnackBar('🔗 Lien créé avec succès !');
      _loadActiveLinks();

      // Afficher le dialogue avec le lien
      _showLinkDialog(link);
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _showLinkDialog(SharingLinkModel link) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Lien de partage créé !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: link.shareUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scannez ce QR Code ou partagez le lien',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Lien
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  link.shareUrl,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link.shareUrl));
                        _showSnackBar('Lien copié !');
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copier'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await Share.share(
                            'Suivez ma position en temps réel pendant mon pèlerinage: ${link.shareUrl}',
                            subject: 'Ma position en temps réel',
                          );
                        } catch (e) {
                          _showSnackBar('Erreur de partage', isError: true);
                        }
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Partager'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _revokeLink(SharingLinkModel link) async {
    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) return;

    try {
      await _sharingService.revokeLink(userId: userId, linkId: link.id);
      _showSnackBar('Lien révoqué');
      _loadActiveLinks();
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager ma position'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Partagez votre position en temps réel avec votre famille via un lien sécurisé',
                              style: TextStyle(color: Colors.green.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Formulaire de création
                  Text(
                    'Créer un nouveau lien',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _familyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du membre de famille (optionnel)',
                      hintText: 'Ex: Épouse, Parents, Enfants',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Message (optionnel)',
                      hintText: 'Ex: Je partage ma position pendant mon voyage',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Durée
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      const Text('Valide pendant:'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _selectedDuration,
                        items: [7, 14, 30, 60, 90, 180, 365]
                            .map((days) => DropdownMenuItem(
                                  value: days,
                                  child: Text('$days jours'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedDuration = value!);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createNewLink,
                      icon: const Icon(Icons.add_link),
                      label: const Text('Créer le lien de partage'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Liste des liens actifs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Liens actifs (${_activeLinks.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_activeLinks.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadActiveLinks,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_activeLinks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.link_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun lien actif',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._activeLinks.map((link) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: link.expired
                                  ? Colors.grey
                                  : Colors.green,
                              child: Icon(
                                link.expired ? Icons.link_off : Icons.link,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              link.familyMemberName ?? 'Lien de partage',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (link.description != null)
                                  Text(link.description!),
                                Text(
                                  'Expire dans ${link.daysUntilExpiration} jour(s)',
                                  style: TextStyle(
                                    color: link.daysUntilExpiration < 7
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.copy, size: 18),
                                      SizedBox(width: 8),
                                      Text('Copier le lien'),
                                    ],
                                  ),
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: link.shareUrl));
                                    _showSnackBar('Lien copié !');
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.qr_code, size: 18),
                                      SizedBox(width: 8),
                                      Text('Voir QR Code'),
                                    ],
                                  ),
                                  onTap: () => _showLinkDialog(link),
                                ),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.share, size: 18),
                                      SizedBox(width: 8),
                                      Text('Partager'),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Share.share(link.shareUrl);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.block, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Révoquer', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  onTap: () => _revokeLink(link),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

