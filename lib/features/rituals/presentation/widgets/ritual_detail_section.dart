import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../data/ritual_guidance.dart';

class RitualDetailSection extends StatefulWidget {
  final RitualModel ritual;
  final String audioLanguage;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onWatchVideo;

  const RitualDetailSection({
    super.key,
    required this.ritual,
    required this.audioLanguage,
    this.onMarkAsCompleted,
    this.onWatchVideo,
  });

  @override
  State<RitualDetailSection> createState() => _RitualDetailSectionState();
}

class _RitualDetailSectionState extends State<RitualDetailSection> {
  final TtsService _tts = sl<TtsService>();
  bool _hasReadExplanation = false;
  bool _hasWatchedVideo = false;

  /// Guide détaillé PROPRE à ce rituel (4 axes), sinon null.
  RitualGuidance? get _guidance =>
      guidanceFor(widget.ritual.id, widget.ritual.name);

  @override
  void initState() {
    super.initState();
    _tts.onError = _showMessage;
    _tts.addListener(_onTtsChanged);
  }

  void _onTtsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tts.removeListener(_onTtsChanged);
    if (_tts.currentTag == widget.ritual.id) {
      _tts.stop();
    }
    _tts.onError = null;
    super.dispose();
  }

  bool get _isSpeaking =>
      _tts.isSpeaking && _tts.currentTag == widget.ritual.id;

  /// Lit l'explication détaillée du rituel à voix haute (synthèse vocale).
  /// Remplace les anciens mp3 `assets/audio/...` absents du bundle.
  Future<void> _playExplanation() async {
    final guidance = _guidance;
    final text = (guidance != null && !_isServerGendered)
        ? guidance.toSpeech(widget.ritual.name)
        : '${widget.ritual.name}. ${_getDetailedExplanation()}. '
            '${_getImportantSteps().join('. ')}';
    setState(() => _hasReadExplanation = true);
    await _tts.speak(text, lang: widget.audioLanguage, tag: widget.ritual.id);
  }

  Future<void> _pauseExplanation() async {
    await _tts.stop();
  }

  Future<void> _watchVideo() async {
    final videoUrl = widget.ritual.getVideoUrl(widget.audioLanguage);

    if (videoUrl == null || videoUrl.isEmpty) {
      _showMessage('Aucune vidéo disponible pour ce rituel');
      return;
    }

    try {
      final uri = Uri.parse(videoUrl);

      // Extraire l'ID YouTube
      final youtubeId = _extractYouTubeId(videoUrl);

      // Essayer d'ouvrir dans l'app YouTube
      if (youtubeId != null) {
        final youtubeAppUri = Uri.parse('vnd.youtube:$youtubeId');

        if (await canLaunchUrl(youtubeAppUri)) {
          await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
          setState(() {
            _hasWatchedVideo = true;
          });
          widget.onWatchVideo?.call();
          return;
        }
      }

      // Fallback: ouvrir dans le navigateur
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() {
          _hasWatchedVideo = true;
        });
        widget.onWatchVideo?.call();
      } else {
        _showMessage(
            'Impossible d\'ouvrir la vidéo. Vérifiez que YouTube est installé.');
      }
    } catch (e) {
      _showMessage('Erreur lors de l\'ouverture de la vidéo: $e');
    }
  }

  /// Extrait l'ID de la vidéo YouTube depuis l'URL
  String? _extractYouTubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\?\/]+)',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  void _markAsCompleted() {
    widget.onMarkAsCompleted?.call();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _canMarkAsCompleted {
    // Le pèlerin peut marquer un rite accompli à tout moment (plus de blocage
    // "il faut d'abord écouter/regarder" : il rendait le bouton inerte).
    return widget.ritual.status != RitualStatus.completed &&
        widget.ritual.status != RitualStatus.overdue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4FC3F7),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Explication détaillée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Explication complète du rituel
          _buildExplanationSection(),
          const SizedBox(height: 20),

          // Boutons audio et vidéo
          _buildMediaButtons(),
          const SizedBox(height: 20),

          // Bouton "Marquer comme fait"
          _buildMarkAsCompletedButton(),
        ],
      ),
    );
  }

  Widget _buildExplanationSection() {
    final steps = _getImportantSteps();
    final howTo = _getHowTo();
    final security = _getSecurity();
    final info = _getPracticalInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description principale
        Text(
          _getDetailedExplanation(),
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Étapes importantes (ce qui est important à faire)
        _buildListBlock(
          title: 'Étapes importantes',
          icon: Icons.list_alt,
          color: const Color(0xFF4FC3F7),
          background: const Color(0xFFF0F9FF),
          items: steps,
          numbered: true,
        ),

        // Comment l'accomplir (possibilités / variantes)
        if (howTo.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildListBlock(
            title: 'Comment l\'accomplir',
            icon: Icons.checklist_rtl,
            color: const Color(0xFF10B981),
            background: const Color(0xFFECFDF5),
            items: howTo,
            numbered: false,
          ),
        ],

        // Sécurité
        if (security.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildListBlock(
            title: 'Sécurité',
            icon: Icons.health_and_safety_outlined,
            color: const Color(0xFFEF4444),
            background: const Color(0xFFFEF2F2),
            items: security,
            numbered: false,
          ),
        ],

        // Conseils pratiques
        if (info.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTipsBlock(info),
        ],
      ],
    );
  }

  /// Bloc générique « titre + liste » avec puces ou numéros.
  Widget _buildListBlock({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
    required List<String> items,
    required bool numbered,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  numbered
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Icon(Icons.circle, size: 8, color: color),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsBlock(Map<String, String> info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                'Conseils pratiques',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...info.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMediaButtons() {
    final isLoading = _tts.state == TtsState.loading && _isSpeaking;
    return Row(
      children: [
        // Bouton Audio (synthèse vocale de l'explication)
        Expanded(
          child: _buildMediaButton(
            icon: isLoading
                ? Icons.hourglass_top
                : (_isSpeaking ? Icons.stop : Icons.play_arrow),
            label: _isSpeaking ? 'Arrêter' : 'Écouter l\'explication',
            color: const Color(0xFF4FC3F7),
            onPressed: _isSpeaking ? _pauseExplanation : _playExplanation,
            isEnabled: true,
          ),
        ),
        const SizedBox(width: 12),

        // Bouton Vidéo
        Expanded(
          child: _buildMediaButton(
            icon: Icons.play_circle_outline,
            label: 'Regarder la vidéo',
            color: const Color(0xFF8B5CF6),
            onPressed: _watchVideo,
            isEnabled: widget.ritual.getVideoUrl(widget.audioLanguage) != null,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        foregroundColor: isEnabled ? color : Colors.grey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMarkAsCompletedButton() {
    final isCompleted = widget.ritual.status == RitualStatus.completed;
    final isOverdue = widget.ritual.status == RitualStatus.overdue;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canMarkAsCompleted ? _markAsCompleted : null,
        icon: Icon(
          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
          size: 24,
        ),
        label: Text(
          isCompleted
              ? '✅ Rituel accompli'
              : isOverdue
                  ? '❌ Rituel manqué'
                  : 'Marquer comme accompli',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : isOverdue
                  ? Colors.grey.withValues(alpha: 0.1)
                  : _canMarkAsCompleted
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
          foregroundColor: isCompleted
              ? const Color(0xFF10B981)
              : isOverdue
                  ? Colors.grey
                  : _canMarkAsCompleted
                      ? const Color(0xFF10B981)
                      : Colors.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  // --- Contenu : guide propre au rituel, sinon données du modèle, sinon
  //     repli générique. ----------------------------------------------------

  /// Le serveur a-t-il fourni un contenu d'étapes déjà filtré/varié par genre ?
  /// Si oui, il fait AUTORITÉ : la guidance statique (prose mixte homme/femme,
  /// codée en dur) ne doit plus s'afficher, sinon une femme verrait p.ex. la
  /// tenue blanche réservée aux hommes et le changement de profil n'aurait aucun
  /// effet visible.
  bool get _isServerGendered => widget.ritual.steps.isNotEmpty;

  String _getDetailedExplanation() {
    if (_isServerGendered && widget.ritual.description.isNotEmpty) {
      return widget.ritual.description;
    }
    final g = _guidance;
    if (g != null) return g.explanation;
    if (widget.ritual.description.isNotEmpty) return widget.ritual.description;
    return 'Ce rituel fait partie intégrante du Hadj. Suivez attentivement les instructions.';
  }

  List<String> _getImportantSteps() {
    // Priorité au contenu gendré du serveur.
    if (_isServerGendered) return widget.ritual.steps;
    final g = _guidance;
    if (g != null) return g.importantSteps;
    return [
      'Maintenez votre pureté rituelle (wudu)',
      'Récitez des invocations sincères',
      'Respectez les autres pèlerins',
      'Suivez les instructions des autorités religieuses',
    ];
  }

  List<String> _getHowTo() {
    // Pour un rite gendré, on n'affiche pas le "comment" statique mixte
    // (il contiendrait des actes de l'autre genre).
    if (_isServerGendered) return const [];
    return _guidance?.howTo ?? const [];
  }

  List<String> _getSecurity() {
    return _guidance?.security ?? const [];
  }

  Map<String, String> _getPracticalInfo() {
    if (_isServerGendered && widget.ritual.practicalTips.isNotEmpty) {
      return widget.ritual.practicalTips;
    }
    final g = _guidance;
    if (g != null) return g.practicalTips;
    if (widget.ritual.practicalTips.isNotEmpty) {
      return widget.ritual.practicalTips;
    }
    return {
      'Conseil': 'Suivez votre guide',
      'Focus': 'Sincérité et dévotion',
    };
  }
}
