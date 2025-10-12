import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/ritual_model.dart';

/// 🤖 Assistant virtuel intelligent qui guide le pèlerin comme un vrai accompagnateur
class VirtualGuideAssistant extends ConsumerStatefulWidget {
  final RitualModel ritual;
  final VoidCallback? onStartRitual;
  final VoidCallback? onNeedHelp;

  const VirtualGuideAssistant({
    super.key,
    required this.ritual,
    this.onStartRitual,
    this.onNeedHelp,
  });

  @override
  ConsumerState<VirtualGuideAssistant> createState() => _VirtualGuideAssistantState();
}

class _VirtualGuideAssistantState extends ConsumerState<VirtualGuideAssistant> {
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  void _initializeConversation() {
    setState(() {
      _currentMessage = _getGreetingMessage();
    });
  }

  String _getGreetingMessage() {
    // Message simple et direct selon le statut
    return _getRitualExplanation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F9FF), // Bleu très clair
            Color(0xFFFFFBEB), // Jaune très clair
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuideHeader(),
          const SizedBox(height: 16),
          _buildConversationBubble(),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildGuideHeader() {
    return Row(
      children: [
        // Avatar simple sans animation
        Container(
          width: 48,
          height: 48,
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
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explication détaillée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3557),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Text(
        _currentMessage,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = _getContextualActions();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) => _buildActionChip(action)).toList(),
    );
  }

  List<QuickAction> _getContextualActions() {
    // Actions simples et essentielles uniquement
    return [
      QuickAction(
        icon: Icons.headphones,
        label: 'Écouter l\'explication',
        color: const Color(0xFF8B5CF6),
        onTap: () => _playAudioGuide(),
      ),
      QuickAction(
        icon: Icons.play_circle_outline,
        label: 'Regarder la vidéo',
        color: const Color(0xFFEF4444),
        onTap: () => _playVideoGuide(),
      ),
    ];
  }

  Widget _buildActionChip(QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: action.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              size: 18,
              color: action.color,
            ),
            const SizedBox(width: 6),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getRitualExplanation() {
    switch (widget.ritual.name.toLowerCase()) {
      case 'tawaf':
        return '''🕋 **Le Tawaf** est l'un des actes les plus sacrés du Hadj.

**Voici comment procéder :**
1️⃣ Commencez à la Pierre Noire (Hajar al-Aswad)
2️⃣ Faites 7 tours autour de la Kaaba dans le sens inverse des aiguilles d'une montre
3️⃣ À chaque passage devant la Pierre Noire, dites "Bismillah Allahu Akbar"
4️⃣ Récitez des invocations pendant vos tours

**Conseils pratiques :**
⏱️ Durée : 30-45 minutes
💧 Restez hydraté
🤲 Concentrez-vous sur vos invocations

Je suis là si vous avez des questions !''';

      case 'sa\'i':
        return '''🏃 **Le Sa'i** commémore le parcours de Hajar entre Safa et Marwa.

**Comment faire :**
1️⃣ Commencez à la colline de Safa
2️⃣ Marchez vers Marwa en récitant des douas
3️⃣ Entre les piliers verts, les hommes doivent courir légèrement
4️⃣ Faites 7 allers-retours (Safa → Marwa = 1, Marwa → Safa = 2)

**Points importants :**
⏱️ Durée : 20-30 minutes
🚶 Prenez votre temps
💚 Rappelez-vous l'histoire de Hajar

Prêt à commencer ? Je vous guide !''';

      default:
        return '''✨ **${widget.ritual.name}** est une étape importante de votre parcours spirituel.

Je vais vous accompagner pas à pas pour que tout se passe bien. N'hésitez pas à me poser toutes vos questions !

Voulez-vous que je vous explique les étapes en détail ? 🤝''';
    }
  }

  void _playAudioGuide() {
    // Juste déclencher l'audio, pas de message
    // Logique sera gérée par le parent
  }

  void _playVideoGuide() {
    // Juste déclencher la vidéo, pas de message
    // Logique sera gérée par le parent
  }

}

// Modèles de données
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

