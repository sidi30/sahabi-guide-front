import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/dua_model.dart';
import '../providers/rituals_state_manager.dart';
import '../widgets/dua_player_widget.dart';
import '../widgets/dua_card_widget.dart';

class InteractiveDouaPage extends StatefulWidget {
  const InteractiveDouaPage({super.key});

  @override
  State<InteractiveDouaPage> createState() => _InteractiveDouaPageState();
}

class _InteractiveDouaPageState extends State<InteractiveDouaPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Toutes';
  String _selectedLanguage = 'fr';

  final List<String> _categories = [
    'Toutes',
    'Hajj',
    'Quotidiennes',
    'Protection',
    'Gratitude',
    'Favoris',
  ];

  final Map<String, String> _languages = {
    'fr': 'Français',
    'ha': 'Haoussa',
    'za': 'Zarma',
    'ar': 'Arabe',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RitualsStateManager>().loadDuas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mes Douas',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildLanguageSelector(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF4FC3F7),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4FC3F7),
          onTap: (index) {
            setState(() {
              _selectedCategory = _categories[index];
            });
          },
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Current playing dua
          Consumer<RitualsStateManager>(
            builder: (context, stateManager, child) {
              if (stateManager.currentPlayingDua != null) {
                return DuaPlayerWidget(
                  dua: stateManager.currentPlayingDua!,
                  onPause: () => stateManager.pauseDua(),
                  onResume: () => stateManager.resumeDua(),
                  onStop: () => stateManager.stopDua(),
                  onToggleLoop: () => context.read<RitualsStateManager>()._audioService.toggleLoop(),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Douas list
          Expanded(
            child: Consumer<RitualsStateManager>(
              builder: (context, stateManager, child) {
                if (stateManager.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                    ),
                  );
                }

                final filteredDuas = _filterDuas(stateManager.duas);

                if (filteredDuas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune doua trouvée',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choisissez une autre catégorie',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    return DuaCardWidget(
                      dua: dua,
                      selectedLanguage: _selectedLanguage,
                      onPlay: () => stateManager.playDua(dua),
                      onToggleFavorite: () => stateManager.toggleDuaFavorite(dua.id),
                      onShowDetails: () => _showDuaDetails(dua),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Color(0xFF1D3557)),
      onSelected: (language) {
        setState(() {
          _selectedLanguage = language;
        });
        context.read<RitualsStateManager>().setLanguage(language);
      },
      itemBuilder: (context) {
        return _languages.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Text(entry.value),
                if (entry.key == _selectedLanguage) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, color: Color(0xFF4FC3F7), size: 16),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }

  List<DuaModel> _filterDuas(List<DuaModel> duas) {
    switch (_selectedCategory) {
      case 'Hajj':
        return duas.where((d) => d.type == DuaType.hajj).toList();
      case 'Quotidiennes':
        return duas.where((d) => d.type == DuaType.daily).toList();
      case 'Protection':
        return duas.where((d) => d.type == DuaType.protection).toList();
      case 'Gratitude':
        return duas.where((d) => d.type == DuaType.gratitude).toList();
      case 'Favoris':
        return duas.where((d) => d.isFavorite).toList();
      default:
        return duas;
    }
  }

  void _showDuaDetails(DuaModel dua) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dua.getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        dua.getTypeIcon(),
                        color: dua.getTypeColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dua.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                          Text(
                            dua.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<RitualsStateManager>().toggleDuaFavorite(dua.id),
                      icon: Icon(
                        dua.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: dua.isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dua.arabicText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D3557),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Transliteration
                      Text(
                        'Transliteration',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.transliteration,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Translation
                      Text(
                        'Traduction',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dua.getTranslation(_selectedLanguage),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Audio controls
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.read<RitualsStateManager>().playDua(dua),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Écouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FC3F7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.read<RitualsStateManager>().playDua(dua),
                            icon: const Icon(Icons.repeat),
                            label: const Text('En boucle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4FC3F7),
                              side: const BorderSide(color: Color(0xFF4FC3F7)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}