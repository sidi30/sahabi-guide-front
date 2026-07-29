import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/ritual_model.dart';
import '../../data/ritual_guidance.dart';
import '../../data/rite_images.dart';
import 'step_reader_page.dart';

class RitualDetailSection extends StatefulWidget {
  final RitualModel ritual;
  final String audioLanguage;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onWatchVideo;

  /// 'MALE'/'FEMALE' : voix d'écoute (homme/femme) dans le lecteur.
  final String? gender;

  /// Rite marqué accompli on-device (pour la page de fin du lecteur).
  final bool isDone;

  const RitualDetailSection({
    super.key,
    required this.ritual,
    required this.audioLanguage,
    this.onMarkAsCompleted,
    this.onWatchVideo,
    this.gender,
    this.isDone = false,
  });

  @override
  State<RitualDetailSection> createState() => _RitualDetailSectionState();
}

class _RitualDetailSectionState extends State<RitualDetailSection> {
  final TtsService _tts = sl<TtsService>();

  /// Guide détaillé PROPRE à ce rituel (4 axes), sinon null.
  ///
  /// TODO(refonte-genre) cf. docs/refonte-genre-rites.md : `ritual_guidance.dart`
  /// est la source de vérité n°2 (prose française mixte, codée en dur). Elle doit
  /// être SUPPRIMÉE une fois tous les rites migrés en schemaVersion 2 côté serveur.
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
    // La guidance statique n'est jamais lue à une pèlerine (prose masculine).
    final body = (guidance != null && !_isServerGendered && !_hidesStaticGuidance)
        ? guidance.toSpeech(widget.ritual.name)
        : '${widget.ritual.name}. ${_getDetailedExplanation()}. '
            '${_getImportantSteps().join('. ')}';
    // Le mode dégradé est ANNONCÉ à voix haute : sinon l'auditrice/l'auditeur
    // prendrait un contenu générique pour son contenu personnalisé.
    final l10n = AppLocalizations.of(context)!;
    final text = _isDegradedFallback
        ? '${l10n.rituals_fallback_notice_title}. ${_fallbackNoticeBody(l10n)} $body'
        : body;
    await _tts.speak(text,
        lang: widget.audioLanguage, tag: widget.ritual.id, gender: widget.gender);
  }

  Future<void> _pauseExplanation() async {
    await _tts.stop();
  }

  Future<void> _watchVideo() async {
    final videoUrl = widget.ritual.getVideoUrl(widget.audioLanguage);
    final l10n = AppLocalizations.of(context)!;

    if (videoUrl == null || videoUrl.isEmpty) {
      _showMessage(l10n.ritual_detail_no_video);
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
          widget.onWatchVideo?.call();
          return;
        }
      }

      // Fallback: ouvrir dans le navigateur
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        widget.onWatchVideo?.call();
      } else {
        _showMessage(l10n.ritual_detail_video_open_failed);
      }
    } catch (e) {
      _showMessage(l10n.ritual_detail_video_error(e.toString()));
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

  /// Ouvre le lecteur « comme un livre » (une étape par page, texte en grand,
  /// images zoomables plein écran, vidéo). [startAt] = étape sur laquelle démarrer.
  void _openReader(int startAt) {
    final steps = _getImportantSteps();
    if (steps.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StepReaderPage(
        ritualName: widget.ritual.name,
        ritualDescription: _getDetailedExplanation(),
        steps: steps,
        images: imagesForRitual(widget.ritual.name),
        videoUrl: widget.ritual.getVideoUrl(widget.audioLanguage),
        audioLanguage: widget.audioLanguage,
        gender: widget.gender,
        isCompleted:
            widget.isDone || widget.ritual.status == RitualStatus.completed,
        onToggleCompleted: widget.onMarkAsCompleted,
        initialIndex: startAt,
      ),
    ));
  }

  void _openImage(int index) {
    final imgs = imagesForRitual(widget.ritual.name);
    if (imgs.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => FullscreenImageViewer(images: imgs, initialIndex: index),
    ));
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
              Text(
                AppLocalizations.of(context)!.ritual_detail_explanation_title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Illustrations officielles (guide Ihram HAJ.GOV.SA), le cas échéant.
          _buildImageGallery(),

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
    final explanation = _getDetailedExplanation();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repli sur du contenu non personnalisé : le signaler AVANT le contenu.
        if (_isDegradedFallback) _buildFallbackNotice(),

        // Description principale
        if (explanation.isNotEmpty)
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 20),

        // Bouton « livre » : ouvre chaque étape en grand (lecture confortable).
        if (steps.isNotEmpty) _buildOpenReaderButton(),
        if (steps.isNotEmpty) const SizedBox(height: 16),

        // Étapes importantes (ce qui est important à faire).
        // Tap sur une étape -> l'ouvre en grand dans le lecteur.
        if (steps.isNotEmpty)
          _buildListBlock(
            title: l10n.ritual_detail_steps_title,
            icon: Icons.list_alt,
            color: const Color(0xFF4FC3F7),
            background: const Color(0xFFF0F9FF),
            items: steps,
            numbered: true,
            onItemTap: _openReader,
          ),

        // Comment l'accomplir (possibilités / variantes)
        if (howTo.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildListBlock(
            title: l10n.ritual_detail_howto_title,
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
            title: l10n.ritual_detail_security_title,
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

  /// Grand bouton d'appel : lire les étapes une par une en plein écran.
  Widget _buildOpenReaderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openReader(0),
        icon: const Icon(Icons.menu_book, size: 22),
        label: Text(
          AppLocalizations.of(context)!.ritual_detail_read_steps,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D3557),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  /// Bloc générique « titre + liste » avec puces ou numéros.
  /// [onItemTap] (facultatif) rend chaque ligne cliquable (ouvre le lecteur).
  Widget _buildListBlock({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
    required List<String> items,
    required bool numbered,
    void Function(int index)? onItemTap,
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
            final row = Row(
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
                    maxLines: onItemTap != null ? 2 : null,
                    overflow: onItemTap != null ? TextOverflow.ellipsis : null,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
                // Indice « ouvrir en grand »
                if (onItemTap != null)
                  Icon(Icons.open_in_full, size: 16, color: color),
              ],
            );
            if (onItemTap == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: row,
              );
            }
            return InkWell(
              onTap: () => onItemTap(index),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: row,
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
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.ritual_detail_tips_title,
                style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Bouton Audio (synthèse vocale de l'explication)
        Expanded(
          child: _buildMediaButton(
            icon: isLoading
                ? Icons.hourglass_top
                : (_isSpeaking ? Icons.stop : Icons.play_arrow),
            label: _isSpeaking
                ? l10n.ritual_detail_stop
                : l10n.ritual_detail_listen,
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
            label: l10n.ritual_detail_watch_video,
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

  /// Galerie d'illustrations officielles du rite (guide Ihram HAJ.GOV.SA).
  /// Carrousel horizontal avec légende par section. Rien si aucune image.
  Widget _buildImageGallery() {
    final imgs = imagesForRitual(widget.ritual.name);
    if (imgs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: imgs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final im = imgs[i];
            return GestureDetector(
              onTap: () => _openImage(i),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.asset(
                    im.asset,
                    width: 270,
                    height: 190,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 270, height: 190),
                  ),
                  // Pastille zoom en haut à droite
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Container(
                    width: 270,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      im.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarkAsCompletedButton() {
    final isCompleted = widget.ritual.status == RitualStatus.completed;
    final isOverdue = widget.ritual.status == RitualStatus.overdue;
    final l10n = AppLocalizations.of(context)!;

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
              ? '✅ ${l10n.ritual_detail_done}'
              : isOverdue
                  ? '❌ ${l10n.ritual_detail_missed}'
                  : l10n.ritual_detail_mark_done,
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

  /// Profil courant féminin (bascule Homme/Femme de la page rites).
  bool get _isFemale => widget.gender?.toUpperCase() == 'FEMALE';

  /// Aucune étape serveur : on retombe sur la guidance statique (ou sur le repli
  /// générique). Arrive quand le rite n'est pas encore migré en schemaVersion 2,
  /// que le JSON est illisible côté serveur, hors-ligne sans cache, ou sur erreur
  /// API. Le contenu affiché n'est alors ni personnalisé ni traduit : on le DIT.
  bool get _isDegradedFallback => !_isServerGendered;

  /// La guidance statique est une prose mixte contenant des actes explicitement
  /// masculins (Idtiba', Raml, Halq/Taqsir) : on ne la sert jamais à une pèlerine.
  /// Un bandeau seul vaut mieux qu'un contenu faux.
  bool get _hidesStaticGuidance => _isDegradedFallback && _isFemale;

  String _fallbackNoticeBody(AppLocalizations l10n) => _hidesStaticGuidance
      ? l10n.rituals_fallback_female_body
      : l10n.rituals_fallback_notice_body;

  /// Bandeau de mode dégradé : rend le repli VISIBLE au lieu de le taire.
  Widget _buildFallbackNotice() {
    final l10n = AppLocalizations.of(context)!;
    const amber = Color(0xFFB45309);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: amber.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rituals_fallback_notice_title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amber,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fallbackNoticeBody(l10n),
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedExplanation() {
    if (_isServerGendered && widget.ritual.description.isNotEmpty) {
      return widget.ritual.description;
    }
    if (_hidesStaticGuidance) {
      // Seul du contenu serveur (neutre) est admis ici, jamais la prose statique.
      if (widget.ritual.description.isNotEmpty) return widget.ritual.description;
      return '';
    }
    final g = _guidance;
    if (g != null) return g.explanation;
    if (widget.ritual.description.isNotEmpty) return widget.ritual.description;
    return 'Ce rituel fait partie intégrante du Hadj. Suivez attentivement les instructions.';
  }

  List<String> _getImportantSteps() {
    // Priorité au contenu gendré du serveur.
    if (_isServerGendered) return widget.ritual.steps;
    if (_hidesStaticGuidance) return const [];
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
    if (_isServerGendered || _hidesStaticGuidance) return const [];
    return _guidance?.howTo ?? const [];
  }

  List<String> _getSecurity() {
    // La section « Sécurité » statique porte aussi des consignes genrées
    // (« (homme) », « Femmes : … ») : hors sujet pour un profil féminin en repli.
    if (_hidesStaticGuidance) return const [];
    return _guidance?.security ?? const [];
  }

  Map<String, String> _getPracticalInfo() {
    if (_isServerGendered && widget.ritual.practicalTips.isNotEmpty) {
      return widget.ritual.practicalTips;
    }
    if (_hidesStaticGuidance) return widget.ritual.practicalTips;
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
