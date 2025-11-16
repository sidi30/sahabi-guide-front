import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bot_provider.dart';
import '../widgets/bot_message_bubble.dart';
import '../widgets/quick_reply_chip.dart';
import '../widgets/gps_debug_panel.dart';
import 'bot_settings_page.dart';

/// Page principale du chat bot Hajj
class BotChatPage extends ConsumerStatefulWidget {
  const BotChatPage({super.key});

  @override
  ConsumerState<BotChatPage> createState() => _BotChatPageState();
}

class _BotChatPageState extends ConsumerState<BotChatPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<AnimationController> _animationControllers = [];

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
    final state = ref.watch(botChatProvider);

    // Affiche l'erreur si présente
    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assistant Hajj')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur d\'initialisation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(botChatProvider.notifier).initialize();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: state.isLoading
          ? _buildLoadingState()
          : _buildChatInterface(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final state = ref.watch(botChatProvider);
    
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bot.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.smart_toy_rounded,
                    color: Color(0xFF1D3557),
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Assistant Hajj',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Guide pas à pas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        const GpsDebugButton(),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: _openSettings,
          tooltip: 'Paramètres',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _showRestartDialog,
          tooltip: 'Recommencer',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: _showStatsDialog,
          tooltip: 'Statistiques',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: _buildProgressBar(state.progressPercentage),
      ),
    );
  }

  Widget _buildProgressBar(int progress) {
    return LinearProgressIndicator(
      value: progress / 100,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        progress >= 100 ? Colors.green : const Color(0xFF06D6A0),
      ),
      minHeight: 6,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Initialisation du bot...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface(BotChatState state) {
    // Crée les contrôleurs d'animation pour les nouveaux messages
    while (_animationControllers.length < state.messages.length) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animationControllers.add(controller);
      controller.forward();
    }

    // Scroll automatique vers le bas
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
        if (state.conversationStarted) _buildProgressBadge(state),
        
        // Messages
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      return _buildTypingIndicator();
                    }

                    final message = state.messages[index];
                    final animation = _animationControllers[index];

                    return BotMessageBubble(
                      message: message,
                      animation: animation,
                    );
                  },
                ),
        ),

        // Réponses rapides
        if (state.messages.isNotEmpty && !state.isTyping)
          _buildQuickReplies(state),

        // Zone de saisie
        _buildInputArea(state),
      ],
    );
  }

  Widget _buildProgressBadge(BotChatState state) {
    final progress = state.progressPercentage;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: progress >= 100 ? Colors.green[50] : const Color(0xFF06D6A0).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: progress >= 100 ? Colors.green[200]! : const Color(0xFF06D6A0).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            progress >= 100 ? Icons.check_circle_rounded : Icons.trending_up_rounded,
            size: 18,
            color: progress >= 100 ? Colors.green[700] : const Color(0xFF1D3557),
          ),
          const SizedBox(width: 8),
          Text(
            progress >= 100
                ? '🎉 Félicitations ! Hajj terminé'
                : 'Progression : $progress%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: progress >= 100 ? Colors.green[700] : const Color(0xFF1D3557),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1D3557).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 60,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bienvenue dans votre\nguide du Hajj ! 🕋',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Je vais vous accompagner étape par étape\ntout au long de votre pèlerinage',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(botChatProvider.notifier).startConversation(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Commencer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D3557),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0.3, end: 1.0),
                    onEnd: () => setState(() {}),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(BotChatState state) {
    if (state.messages.isEmpty) return const SizedBox.shrink();
    
    final lastMessage = state.messages.last;
    if (!lastMessage.isBot || lastMessage.quickReplies == null) {
      return const SizedBox.shrink();
    }

    return QuickReplyList(
      replies: lastMessage.quickReplies!,
      onReplySelected: (reply) => ref.read(botChatProvider.notifier).sendAnswer(reply),
      isEnabled: !state.isTyping,
    );
  }

  Widget _buildInputArea(BotChatState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              enabled: !state.isTyping,
              decoration: InputDecoration(
                hintText: 'Posez une question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF1D3557)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: state.isTyping ? null : _handleTextInput,
                  color: const Color(0xFF1D3557),
                ),
              ),
              onSubmitted: (_) => _handleTextInput(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTextInput() {
    if (_textController.text.trim().isEmpty) return;
    
    final text = _textController.text.trim();
    _textController.clear();
    
    ref.read(botChatProvider.notifier).askQuestion(text);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BotSettingsPage(),
      ),
    );
  }

  Future<void> _showRestartDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommencer ?'),
        content: const Text(
          'Voulez-vous vraiment recommencer la conversation depuis le début ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D3557),
            ),
            child: const Text('Recommencer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(botChatProvider.notifier).restartConversation();
    }
  }

  void _showStatsDialog() {
    final stats = ref.read(botChatProvider.notifier).getStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Statistiques'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 Progression',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildStatRow('Étape actuelle', stats['current_step']),
              _buildStatRow('Étape', '${stats['current_order']} / ${stats['total_steps']}'),
              _buildStatRow('Progression', '${stats['progress_percentage']}%'),
              _buildStatRow('Messages', '${stats['messages_count']}'),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              const Text(
                '📍 Localisation GPS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Lieu actuel',
                stats['current_location'] ?? 'Non détecté',
              ),
              _buildStatRow(
                'Dans lieu saint',
                stats['is_in_holy_place'] == true ? 'Oui ✅' : 'Non',
              ),
              _buildStatRow(
                'Duas suggérées',
                '${stats['suggested_duas_count'] ?? 0}',
              ),
              _buildStatRow(
                'Rappels urgents',
                '${stats['urgent_reminders_count'] ?? 0}',
              ),
            ],
          ),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

