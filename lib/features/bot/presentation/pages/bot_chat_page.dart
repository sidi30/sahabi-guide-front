import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahabi_guide/core/providers/language_provider.dart';
import 'package:sahabi_guide/features/settings/presentation/providers/settings_provider.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import '../providers/bot_provider.dart';
import '../widgets/bot_message_bubble.dart';
import '../widgets/quick_reply_chip.dart';
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
  // Contrôleurs d'animation d'entrée indexés par id de message : le cycle de
  // vie suit le message (pas l'index), donc restartConversation ne désynchronise
  // plus rien et on peut purger les contrôleurs des messages disparus.
  final Map<String, AnimationController> _animationControllers = {};
  // Nombre de messages au dernier build : sert à ne déclencher l'auto-scroll
  // que lorsqu'un message est réellement ajouté (évite la tempête de scroll).
  int _lastMessageCount = 0;
  // Animation des "points" de l'indicateur de saisie : un seul contrôleur en
  // boucle plutôt qu'un TweenAnimationBuilder qui appelait setState à chaque
  // cycle (rebuild ~2x/s -> tempête de scroll).
  late final AnimationController _typingController;

  bool _isListening = false;
  String? _currentlySpeakingMessageId;
  bool _conversationMode = false; // mode mains-libres (ecoute auto apres TTS)
  // Surcharge de langue UNIQUEMENT pour les langues « audio-only » (servies par
  // le backend voix mais sans traduction d'interface : dje/yo/sw/wo/bm). Les 4
  // langues principales (fr/en/ar/ha) passent TOUJOURS par la source de vérité
  // unique [languageProvider] (UI + réponse + voix). `null` => on suit l'UI.
  String? _audioOnlyLangOverride;
  bool _lastInputWasVoice = false; // flag : derniere question envoyee par vocal
  int _processedVoiceCount = 0;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voice = ref.read(voiceServiceProvider);
      voice.onSttError = _showSttError;
      voice.onTtsError = _showTtsError;
      voice.initialize();
    });
  }

  /// Langue courante pilotant la réponse du bot ET la synthèse vocale.
  /// Par défaut = source de vérité unique [languageCodeProvider] (alignée sur
  /// la locale d'interface). Une langue « audio-only » sélectionnée dans
  /// l'AppBar prend le pas le temps de la session (sans changer l'UI, faute de
  /// traduction). Code canonique : `fr|en|ar|ha|dje|yo|sw|wo|bm`.
  String get _currentLang =>
      _audioOnlyLangOverride ?? ref.read(languageCodeProvider);

  /// Affiche un message clair quand la synthèse vocale échoue (ex : voix d'une
  /// langue africaine indisponible côté serveur) au lieu de rester muet.
  void _showTtsError(String errorMsg) {
    if (!mounted) return;
    setState(() => _currentlySpeakingMessageId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔊 Lecture vocale indisponible : $errorMsg'),
        backgroundColor: Colors.deepOrange,
        duration: const Duration(seconds: 4),
      ),
    );
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
    _typingController.dispose();
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    // NE PAS disposer le VoiceService ici : il est partagé et détruit avec son
    // provider. On coupe seulement l'audio/écoute en cours en quittant la page.
    final voice = ref.read(voiceServiceProvider);
    voice.stopSpeaking();
    voice.stopListening();
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
    // Source de vérité unique : on observe le code de langue partagé pour que
    // le drapeau de l'AppBar suive le choix courant (et les rebuilds RTL/UI).
    final currentLang = ref.watch(languageCodeProvider);

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
        // Sélecteur de langue de l'assistant.
        //  - Les 4 langues PRINCIPALES (fr/en/ar/ha) pilotent la source de
        //    vérité unique : UI + réponse du bot + voix changent ensemble.
        //  - Les langues « audio-only » (dje/yo/sw/wo/bm) restent disponibles
        //    pour la réponse + la voix, sans toucher l'UI (pas de traduction).
        PopupMenuButton<String>(
          icon: Text(
            _flagFor(currentLang),
            style: const TextStyle(fontSize: 18),
          ),
          tooltip: 'Langue de l\'assistant',
          onSelected: _onLanguageSelected,
          itemBuilder: (_) => _buildLanguageMenuItems(),
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
    // Crée un contrôleur d'animation d'entrée pour chaque message (clé = id).
    final liveIds = <String>{};
    for (final message in state.messages) {
      liveIds.add(message.id);
      final controller = _animationControllers.putIfAbsent(
        message.id,
        () => AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        )..forward(),
      );
      // Garantit que les messages restaurés/redémarrés sont visibles.
      if (controller.status == AnimationStatus.dismissed) controller.forward();
    }
    // Purge les contrôleurs des messages disparus (ex : restartConversation).
    _animationControllers.removeWhere((id, controller) {
      if (liveIds.contains(id)) return false;
      controller.dispose();
      return true;
    });

    // Scroll automatique vers le bas UNIQUEMENT quand un message a été ajouté
    // (sinon chaque rebuild — typing dots inclus — relancerait un animateTo).
    if (state.messages.length != _lastMessageCount) {
      _lastMessageCount = state.messages.length;
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
                    final animation = _animationControllers[message.id] ??
                        const AlwaysStoppedAnimation(1.0);
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
                  child: AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      // Décale la phase de chaque point pour l'effet de vague.
                      final phase = (_typingController.value + index / 3) % 1.0;
                      final opacity = 0.3 + 0.7 * (1 - (phase * 2 - 1).abs());
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
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
                    ? AppLocalizations.of(context)!.bot_listening
                    : AppLocalizations.of(context)!.bot_input_hint,
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
      lang: _currentLang,
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
    // Coupe toute lecture en cours avant de démarrer la nouvelle.
    await voice.stopSpeaking();
    if (!mounted) return;
    setState(() => _currentlySpeakingMessageId = last.id);
    await voice.speak(last.content, lang: _currentLang);
    if (!mounted) return;
    setState(() => _currentlySpeakingMessageId = null);
    // En mode conversation continue, reenclenche le micro apres la lecture
    if (_conversationMode) {
      _autoListen();
    }
  }

  Future<void> _handleSpeak(String messageId, String content) async {
    final voice = ref.read(voiceServiceProvider);
    // Coupe toute lecture en cours (ex : taper Écouter sur B pendant que A
    // parle) avant de démarrer la nouvelle, sinon les deux se chevauchent.
    await voice.stopSpeaking();
    if (!mounted) return;
    setState(() => _currentlySpeakingMessageId = messageId);
    await voice.speak(content, lang: _currentLang);
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

    ref.read(botChatProvider.notifier).askQuestion(text, language: _currentLang);
  }

  /// Les 4 langues principales : elles changent l'UI + la réponse + la voix
  /// ensemble (via la source de vérité unique [languageProvider]).
  static const List<({String code, String label})> _coreLangs = [
    (code: 'fr', label: 'Français'),
    (code: 'en', label: 'English'),
    (code: 'ar', label: 'العربية'),
    (code: 'ha', label: 'Hausa'),
  ];

  /// Langues « audio-only » : réponse + voix uniquement (UI non traduite).
  static const List<({String code, String label})> _audioOnlyLangs = [
    (code: 'dje', label: 'Zarma'),
    (code: 'yo', label: 'Yoruba'),
    (code: 'sw', label: 'Kiswahili'),
    (code: 'wo', label: 'Wolof'),
    (code: 'bm', label: 'Bambara'),
  ];

  /// Applique le choix de langue depuis le sélecteur de l'AppBar.
  Future<void> _onLanguageSelected(String code) async {
    final isCore = _coreLangs.any((l) => l.code == code);
    if (isCore) {
      // Langue principale : pilote la source de vérité unique => l'UI, la
      // réponse du bot et la voix basculent ensemble (+ RTL pour 'ar').
      setState(() => _audioOnlyLangOverride = null);
      await ref.read(languageProvider.notifier).changeLanguageByCode(code);
      // Aligne aussi la langue audio (rituels/duas) sur ce même choix.
      await ref
          .read(settingsProvider.notifier)
          .setAudioLanguage(AudioLanguage.fromCode(code));
    } else {
      // Langue audio-only : réponse + voix seulement, on laisse l'UI inchangée.
      setState(() => _audioOnlyLangOverride = code);
    }
    if (!mounted) return;
    final label = [..._coreLangs, ..._audioOnlyLangs]
        .firstWhere((l) => l.code == code, orElse: () => (code: code, label: code))
        .label;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_flagFor(code)}  $label'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildLanguageMenuItems() {
    PopupMenuItem<String> tile(({String code, String label}) l) {
      return PopupMenuItem<String>(
        value: l.code,
        child: Row(
          children: [
            Text(_flagFor(l.code), style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(l.label),
          ],
        ),
      );
    }

    return [
      ..._coreLangs.map(tile),
      const PopupMenuDivider(),
      ..._audioOnlyLangs.map(tile),
    ];
  }

  /// Emoji drapeau associé à un code de langue de l'assistant.
  String _flagFor(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇬🇧';
      case 'ar':
        return '🇸🇦';
      case 'ha':
        return '🇳🇪'; // Hausa (Niger / Nigeria)
      case 'dje':
        return '🇳🇪'; // Zarma (Niger)
      case 'yo':
        return '🇳🇬'; // Yoruba (Nigeria)
      case 'sw':
        return '🇹🇿'; // Kiswahili (Tanzanie / Afrique de l'Est)
      case 'wo':
        return '🇸🇳'; // Wolof (Sénégal)
      case 'bm':
        return '🇲🇱'; // Bambara (Mali)
      default:
        return '🌍';
    }
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

