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

  bool _isListening = false;
  String? _currentlySpeakingMessageId;
  String _voiceLang = 'fr'; // fr / ha — langue vocale choisie
  bool _conversationMode = false; // mode mains-libres (ecoute auto apres TTS)
  bool _lastInputWasVoice = false; // flag : derniere question envoyee par vocal
  int _processedVoiceCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voice = ref.read(voiceServiceProvider);
      voice.onSttError = _showSttError;
      voice.initialize();
    });
  }

  /// Traduit les codes d'erreur STT de Google en messages explicites.
  void _showSttError(String errorMsg) {
    if (!mounted) return;
    setState(() => _isListening = false);
    final friendly = switch (errorMsg) {
      'error_network' =>
        '📡 Pas d\'internet — la reconnaissance vocale nécessite une connexion (même sur émulateur)',
      'error_network_timeout' =>
        '⏱️ Réseau trop lent pour la reconnaissance vocale',
      'error_no_match' =>
        '🤔 Je n\'ai pas compris, réessayez en parlant plus clairement',
      'error_speech_timeout' =>
        '⏱️ Aucune voix détectée. Réessayez en parlant après avoir tapé le micro',
      'error_audio' =>
        '🎙️ Problème micro. Vérifiez les permissions dans Paramètres Android',
      'error_client' =>
        '❌ Erreur client de reconnaissance vocale',
      'error_server' =>
        '❌ Serveur Google Speech indisponible',
      'error_recognizer_busy' =>
        'Reconnaissance déjà en cours, patience...',
      'error_permission' =>
        '🔒 Permission micro refusée. Autorisez dans Paramètres Android',
      _ => 'Erreur vocale : $errorMsg',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendly),
        backgroundColor: Colors.deepOrange,
        duration: const Duration(seconds: 4),
      ),
    );
    // Desactive le mode conversation continue pour eviter un spam d'erreurs
    if (_conversationMode) {
      setState(() => _conversationMode = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    ref.read(voiceServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(botChatProvider);

    // Ecoute les changements de messages pour declencher l'auto-TTS
    // quand la derniere question provenait du micro.
    ref.listen(botChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _maybeAutoSpeak(next);
      }
    });

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
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Micro langue : affichage compact du drapeau actuel
        IconButton(
          icon: Text(
            _voiceLang == 'ha' ? '🇳🇪' : '🇫🇷',
            style: const TextStyle(fontSize: 18),
          ),
          tooltip: 'Langue vocale',
          onPressed: () {
            setState(() => _voiceLang = _voiceLang == 'fr' ? 'ha' : 'fr');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_voiceLang == 'ha'
                    ? 'Voix : Haoussa 🇳🇪'
                    : 'Voix : Français 🇫🇷'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        // Toggle conversation continue (mains-libres)
        IconButton(
          icon: Icon(
            _conversationMode
                ? Icons.headset_mic_rounded
                : Icons.headset_off_rounded,
            color: _conversationMode
                ? const Color(0xFF06D6A0)
                : Colors.white,
          ),
          tooltip: _conversationMode
              ? 'Mode mains-libres activé (désactiver)'
              : 'Activer conversation vocale continue',
          onPressed: () {
            setState(() => _conversationMode = !_conversationMode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_conversationMode
                    ? '🎙️ Mode conversation continue activé'
                    : 'Mode conversation continue désactivé'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: _showHistoryDialog,
          tooltip: 'Mes questions',
        ),
        // Toutes les autres actions regroupees dans un menu pour eviter l'overflow
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: 'Plus',
          onSelected: (v) {
            switch (v) {
              case 'settings':
                _openSettings();
                break;
              case 'restart':
                _showRestartDialog();
                break;
              case 'stats':
                _showStatsDialog();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings_rounded),
                title: Text('Paramètres'),
              ),
            ),
            PopupMenuItem(
              value: 'restart',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh_rounded),
                title: Text('Recommencer'),
              ),
            ),
            PopupMenuItem(
              value: 'stats',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline_rounded),
                title: Text('Statistiques'),
              ),
            ),
          ],
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
    // Crée les contrôleurs d'animation uniquement pour les nouveaux messages
    while (_animationControllers.length < state.messages.length) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animationControllers.add(controller);
      controller.forward();
    }

    // Scroll automatique vers le bas (une seule fois par build)
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

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
                    final isThisSpeaking = _currentlySpeakingMessageId == message.id;

                    return BotMessageBubble(
                      message: message,
                      animation: animation,
                      onSpeak: message.isBot
                          ? () => _handleSpeak(message.id, message.content)
                          : null,
                      onStop: message.isBot ? _handleStopSpeak : null,
                      isSpeaking: isThisSpeaking,
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
                hintText: _isListening
                    ? (_voiceLang == 'ha' ? 'Ina saurara...' : 'Écoute en cours...')
                    : (_voiceLang == 'ha'
                        ? 'Tambayi tambaya ko danna makirafo'
                        : 'Posez une question ou utilisez le micro'),
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
          const SizedBox(width: 8),
          // Bouton micro
          Material(
            color: _isListening ? Colors.red : const Color(0xFF2A9D8F),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: state.isTyping ? null : _handleMicToggle,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMicToggle() async {
    final voice = ref.read(voiceServiceProvider);
    // Arrete le TTS s'il parle avant d'ouvrir le micro (evite le larsen)
    await voice.stopSpeaking();
    await voice.initialize();
    if (!voice.isSttAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reconnaissance vocale indisponible sur cet appareil'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    if (_isListening) {
      await voice.stopListening();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await voice.startListening(
      lang: _voiceLang,
      onResult: (text, isFinal) {
        if (!mounted) return;
        _textController.text = text;
        if (isFinal) {
          setState(() {
            _isListening = false;
            _lastInputWasVoice = text.trim().isNotEmpty;
          });
          if (text.trim().isNotEmpty) {
            _handleTextInput();
          }
        }
      },
    );
  }

  /// Demarre l'ecoute automatiquement (mode conversation continue)
  Future<void> _autoListen() async {
    if (!mounted || !_conversationMode || _isListening) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || !_conversationMode) return;
    await _handleMicToggle();
  }

  /// Appele quand un nouveau message bot arrive : auto-TTS si input vocal.
  Future<void> _maybeAutoSpeak(BotChatState state) async {
    if (!_lastInputWasVoice) return;
    final botMessages = state.messages.where((m) => m.isBot).toList();
    if (botMessages.length <= _processedVoiceCount) return;
    final last = botMessages.last;
    _processedVoiceCount = botMessages.length;
    _lastInputWasVoice = false; // reset

    final voice = ref.read(voiceServiceProvider);
    setState(() => _currentlySpeakingMessageId = last.id);
    await voice.speak(last.content, lang: _voiceLang);
    if (!mounted) return;
    setState(() => _currentlySpeakingMessageId = null);
    // En mode conversation continue, reenclenche le micro apres la lecture
    if (_conversationMode) {
      _autoListen();
    }
  }

  Future<void> _handleSpeak(String messageId, String content) async {
    final voice = ref.read(voiceServiceProvider);
    setState(() => _currentlySpeakingMessageId = messageId);
    await voice.speak(content, lang: _voiceLang);
    if (mounted) {
      setState(() => _currentlySpeakingMessageId = null);
    }
  }

  Future<void> _handleStopSpeak() async {
    await ref.read(voiceServiceProvider).stopSpeaking();
    if (mounted) {
      setState(() => _currentlySpeakingMessageId = null);
    }
  }

  void _showHistoryDialog() {
    final state = ref.read(botChatProvider);
    final userQuestions = state.messages.where((m) => !m.isBot).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D3557),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Mes questions précédentes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${userQuestions.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: userQuestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Aucune question posée pour le moment.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: userQuestions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, i) {
                          final q = userQuestions[userQuestions.length - 1 - i];
                          final idx = state.messages.indexOf(q);
                          final botAnswer = (idx >= 0 &&
                                  idx + 1 < state.messages.length &&
                                  state.messages[idx + 1].isBot)
                              ? state.messages[idx + 1].content
                              : null;
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  const Color(0xFF06D6A0).withValues(alpha: 0.2),
                              child: Text(
                                '${userQuestions.length - i}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3557),
                                ),
                              ),
                            ),
                            title: Text(
                              q.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: botAnswer != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      botAnswer,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Text(
                              '${q.timestamp.hour.toString().padLeft(2, '0')}:${q.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Scroll to that message in the chat
                              if (idx >= 0 && _scrollController.hasClients) {
                                _scrollController.animateTo(
                                  (idx * 100).toDouble(),
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTextInput() {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();

    ref.read(botChatProvider.notifier).askQuestion(text, language: _voiceLang);
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

