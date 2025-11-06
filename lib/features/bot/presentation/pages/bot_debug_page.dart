import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bot_provider.dart';

/// Page de debug pour identifier les problèmes d'initialisation
class BotDebugPage extends ConsumerStatefulWidget {
  const BotDebugPage({super.key});

  @override
  ConsumerState<BotDebugPage> createState() => _BotDebugPageState();
}

class _BotDebugPageState extends ConsumerState<BotDebugPage> {
  String _logMessage = 'Prêt à tester...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bot Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logMessage,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _testKnowledgeBase,
                    child: const Text('1. Tester KnowledgeBase'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testContextService,
                    child: const Text('2. Tester ContextService'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testStorageService,
                    child: const Text('3. Tester StorageService'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testNotificationService,
                    child: const Text('4. Tester NotificationService'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testLLMService,
                    child: const Text('5. Tester LLMService'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testBotService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('6. Tester BotService (complet)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _log(String message) {
    setState(() {
      _logMessage += '\n[${DateTime.now().toString().split(' ')[1]}] $message';
    });
  }

  Future<void> _testKnowledgeBase() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test KnowledgeBaseService...');

    try {
      final service = ref.read(knowledgeBaseServiceProvider);
      _log('✅ Provider chargé');

      await service.initialize();
      _log('✅ Initialisé');

      final steps = service.getAllSteps();
      _log('✅ ${steps.length} étapes chargées');

      final firstStep = service.getFirstStep();
      _log('✅ Première étape: ${firstStep?.name}');

      _log('🎉 KnowledgeBase OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testContextService() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test ContextService...');

    try {
      final service = ref.read(contextServiceProvider);
      _log('✅ Provider chargé');

      final context = await service.getCurrentContext();
      _log('✅ Contexte récupéré');
      _log('   - Lieu: ${context.currentLocation ?? "Non détecté"}');
      _log('   - Dans lieu saint: ${context.isInHolyPlace}');
      _log('   - Duas: ${context.suggestedDuas.length}');

      _log('🎉 ContextService OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testStorageService() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test StorageService...');

    try {
      final service = ref.read(storageServiceProvider);
      _log('✅ Provider chargé');

      await service.initialize();
      _log('✅ Initialisé');

      final stats = await service.getStorageStats();
      _log('✅ Stats: $stats');

      _log('🎉 StorageService OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testNotificationService() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test NotificationService...');

    try {
      final service = ref.read(notificationServiceProvider);
      _log('✅ Provider chargé');

      await service.initialize();
      _log('✅ Initialisé');

      _log('🎉 NotificationService OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testLLMService() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test LLMService...');

    try {
      final service = ref.read(llmServiceProvider);
      _log('✅ Provider chargé');

      await service.initialize();
      _log('✅ Initialisé');

      final info = service.getInfo();
      _log('✅ Info: $info');

      _log('🎉 LLMService OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBotService() async {
    setState(() {
      _isLoading = true;
      _logMessage = '';
    });
    _log('🔍 Test BotService COMPLET...');

    try {
      final service = ref.read(botServiceProvider);
      _log('✅ Provider chargé');

      await service.initialize();
      _log('✅ Initialisé');

      final stats = service.getStats();
      _log('✅ Stats: $stats');

      _log('🎯 Démarrage conversation...');
      await service.startConversation();
      _log('✅ Conversation démarrée');

      final history = service.getMessageHistory();
      _log('✅ Historique: ${history.length} messages');

      _log('🎉 BotService COMPLET OK !');
    } catch (e, stack) {
      _log('❌ ERREUR: $e');
      _log('Stack: $stack');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

