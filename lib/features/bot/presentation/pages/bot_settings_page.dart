import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bot_provider.dart';

/// Page de paramètres du bot Hajj
class BotSettingsPage extends ConsumerStatefulWidget {
  const BotSettingsPage({super.key});

  @override
  ConsumerState<BotSettingsPage> createState() => _BotSettingsPageState();
}

class _BotSettingsPageState extends ConsumerState<BotSettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _llmEnabled = false;
  String _llmProvider = 'huggingface';
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    
    try {
      final storageService = ref.read(storageServiceProvider);
      
      _llmEnabled = storageService.isLLMEnabled();
      _llmProvider = storageService.getLLMProvider();
      _notificationsEnabled = storageService.areNotificationsEnabled();

      final apiKey = storageService.getLLMApiKey();
      if (apiKey.isNotEmpty) {
        _apiKeyController.text = apiKey;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveLLMSettings() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final llmService = ref.read(llmServiceProvider);
      
      await storageService.setLLMEnabled(_llmEnabled);
      await storageService.setLLMProvider(_llmProvider);
      await storageService.setLLMApiKey(_apiKeyController.text.trim());
      
      // Met à jour le service LLM
      await llmService.setEnabled(_llmEnabled);
      await llmService.setProvider(_llmProvider);
      await llmService.setApiKey(_apiKeyController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Paramètres LLM sauvegardés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      await storageService.setNotificationsEnabled(_notificationsEnabled);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Paramètres de notifications sauvegardés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmer'),
        content: const Text(
          'Voulez-vous vraiment effacer tout l\'historique de conversation ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final storageService = ref.read(storageServiceProvider);
        await storageService.clearConversationHistory();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Historique effacé'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Paramètres du Bot')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du Bot'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section IA/LLM
          _buildSectionHeader('🤖 Intelligence Artificielle (optionnel)'),
          const SizedBox(height: 8),
          _buildLLMSection(),
          
          const SizedBox(height: 32),
          
          // Section Notifications
          _buildSectionHeader('🔔 Notifications'),
          const SizedBox(height: 8),
          _buildNotificationsSection(),
          
          const SizedBox(height: 32),
          
          // Section Stockage
          _buildSectionHeader('💾 Stockage'),
          const SizedBox(height: 8),
          _buildStorageSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLLMSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Activer l\'IA enrichie'),
              subtitle: const Text(
                "Le copilote transmet votre question à Google Gemini "
                "(Google LLC, USA) via notre serveur, en HTTPS, pour "
                "générer la réponse. Aucune donnée d'identité n'est "
                "envoyée. Voir la politique de confidentialité.",
              ),
              value: _llmEnabled,
              onChanged: (value) async {
                setState(() => _llmEnabled = value);
                await _saveLLMSettings();
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A9D8F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1D3557), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Sources authentifiées ancrées côté serveur : "
                      "Coran, Bukhari, Muslim, Tirmidhi, Abu Dawud, Nasai, "
                      "Ibn Majah, Ibn Hanbal. Filtre thématique Islam/Hajj "
                      "en amont. Google ne conserve pas la requête.",
                      style: TextStyle(fontSize: 12),
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

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Activer les notifications'),
              subtitle: const Text(
                'Recevoir des rappels basés sur votre position GPS',
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _saveNotificationSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Effacer l\'historique'),
              subtitle: const Text(
                'Supprimer toutes les conversations sauvegardées',
              ),
              onTap: _clearHistory,
            ),
            
            const Divider(),
            
            FutureBuilder<Map<String, dynamic>>(
              future: Future.value(ref.read(storageServiceProvider).getStorageStats()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final stats = snapshot.data!;
                return Column(
                  children: [
                    _buildStatRow(
                      'Messages sauvegardés',
                      '${stats['messages_count'] ?? 0}',
                    ),
                    _buildStatRow(
                      'Préférences',
                      '${stats['preferences_count'] ?? 0}',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

