import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
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
          SnackBar(content: Text(AppLocalizations.of(context)!.bot_settings_error(e.toString()))),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.bot_settings_llm_saved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.bot_settings_error(e.toString()))),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.bot_settings_notif_saved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.bot_settings_error(e.toString()))),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bot_settings_clear_title),
        content: Text(
          l10n.bot_settings_clear_message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.bot_settings_clear_action),
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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.bot_settings_history_cleared),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.bot_settings_error(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bot_settings_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bot_settings_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section IA/LLM
          _buildSectionHeader(l10n.bot_settings_section_ai),
          const SizedBox(height: 8),
          _buildLLMSection(),

          const SizedBox(height: 32),

          // Section Notifications
          _buildSectionHeader(l10n.bot_settings_section_notifications),
          const SizedBox(height: 8),
          _buildNotificationsSection(),

          const SizedBox(height: 32),

          // Section Stockage
          _buildSectionHeader(l10n.bot_settings_section_storage),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(l10n.bot_settings_enable_ai),
              subtitle: Text(
                l10n.bot_settings_enable_ai_desc,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1D3557), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.bot_settings_sources_info,
                      style: const TextStyle(fontSize: 12),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(l10n.bot_settings_enable_notifs),
              subtitle: Text(
                l10n.bot_settings_enable_notifs_desc,
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.bot_settings_clear_history),
              subtitle: Text(
                l10n.bot_settings_clear_history_desc,
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
                      l10n.bot_settings_messages_saved,
                      '${stats['messages_count'] ?? 0}',
                    ),
                    _buildStatRow(
                      l10n.bot_settings_preferences,
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

