import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/assistant_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_reply_buttons.dart';
import '../widgets/typing_indicator.dart';

class AssistantChatPage extends ConsumerStatefulWidget {
  const AssistantChatPage({super.key});

  @override
  ConsumerState<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends ConsumerState<AssistantChatPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<AnimationController> _animationControllers = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(assistantChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 8),
            Text('Assistant Personnel'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRestart,
            tooltip: 'Recommencer',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showProgressDialog,
            tooltip: 'Statistiques',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: _buildProgressBar(),
        ),
      ),
      body: chatState.when(
        data: (state) => _buildChatInterface(state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildChatInterface(AssistantChatState state) {
    // Crée les contrôleurs d'animation pour les nouveaux messages
    while (_animationControllers.length < state.messages.length) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _animationControllers.add(controller);
      controller.forward();
    }

    // Scroll automatique vers le bas quand nouveaux messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Column(
      children: [
        // Badge de progression
        _buildProgressBadge(),
        // Messages
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return const TypingIndicator();
                    }

                    final message = state.messages[index];
                    final animation = _animationControllers[index];

                    return ChatBubble(
                      message: message,
                      animation: animation,
                    );
                  },
                ),
        ),

        // Boutons de réponse rapide
        if (state.currentQuickReplies.isNotEmpty && !state.isProcessing)
          QuickReplyButtons(
            replies: state.currentQuickReplies,
            onReplySelected: _handleQuickReply,
            isEnabled: !state.isProcessing,
          ),

        // Zone de saisie
        _buildInputArea(state),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Démarrez la conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Commencer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AssistantChatState state) {
    final needsTextInput = state.currentAnswerType == 'TEXT' ||
        state.currentAnswerType == 'DATE' ||
        state.currentAnswerType == 'TIME';

    if (!needsTextInput) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: !state.isProcessing,
              decoration: InputDecoration(
                hintText: 'Votre réponse...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _handleTextAnswer(value);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: state.isProcessing
                ? null
                : () {
                    if (_textController.text.trim().isNotEmpty) {
                      _handleTextAnswer(_textController.text);
                    }
                  },
            child: state.isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(assistantChatProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStart() async {
    await ref.read(assistantChatProvider.notifier).startConversation();
  }

  Future<void> _handleQuickReply(String reply) async {
    setState(() => _isTyping = true);
    
    // Simule un léger délai pour l'effet de frappe
    await Future.delayed(const Duration(milliseconds: 300));
    
    await ref.read(assistantChatProvider.notifier).sendAnswer(reply);
    
    setState(() => _isTyping = false);
  }

  Future<void> _handleTextAnswer(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isTyping = true);
    _textController.clear();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    await ref.read(assistantChatProvider.notifier).sendAnswer(text.trim());
    
    setState(() => _isTyping = false);
  }

  Future<void> _handleRestart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommencer ?'),
        content: const Text(
          'Voulez-vous vraiment recommencer la conversation ? '
          'L\'historique actuel sera effacé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Recommencer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(assistantChatProvider.notifier).restartConversation();
    }
  }

  Future<void> _showProgressDialog() async {
    final stats = await ref.read(assistantChatProvider.notifier).getStats();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Progression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Étapes complétées', 
                '${stats['completedSteps']} / ${stats['totalSteps']}'),
            _buildStatRow('Progression', 
                '${stats['progressPercentage']}%'),
            _buildStatRow('Réponses non synchronisées', 
                '${stats['unsyncedAnswers']}'),
            if (stats['unsyncedAnswers'] > 0) ...[
              const Divider(),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(assistantChatProvider.notifier).syncNow();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Synchronisation lancée')),
                    );
                  }
                },
                icon: const Icon(Icons.sync),
                label: const Text('Synchroniser maintenant'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Barre de progression dans l'AppBar
  Widget _buildProgressBar() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(botServiceProvider).getProgressStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator(value: 0);
        }
        
        final stats = snapshot.data!;
        final progress = stats['progressPercentage'] as int? ?? 0;
        
        return LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 100 ? Colors.green : Colors.blue,
          ),
          minHeight: 4,
        );
      },
    );
  }

  /// Badge de progression en haut du chat
  Widget _buildProgressBadge() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(botServiceProvider).getProgressStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final stats = snapshot.data!;
        final completed = stats['completedSteps'] as int? ?? 0;
        final total = stats['totalSteps'] as int? ?? 0;
        final progress = stats['progressPercentage'] as int? ?? 0;
        
        if (total == 0) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: progress >= 100 
                ? Colors.green[50] 
                : Colors.blue[50],
            border: Border(
              bottom: BorderSide(
                color: progress >= 100 
                    ? Colors.green[200]! 
                    : Colors.blue[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                progress >= 100 ? Icons.check_circle : Icons.analytics,
                size: 16,
                color: progress >= 100 ? Colors.green[700] : Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                progress >= 100
                    ? '🎉 Félicitations ! Toutes les étapes terminées'
                    : '$completed / $total étapes complétées ($progress%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: progress >= 100 ? Colors.green[700] : Colors.blue[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

