import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/models/dua_model.dart';
import '../../domain/repositories/rituals_repository.dart';
import '../widgets/dua_card.dart';
import '../widgets/dua_player.dart';

// Provider pour récupérer les duas
final duasModernProvider = FutureProvider<List<DuaModel>>((ref) async {
  final repository = sl<RitualsRepository>();
  return await repository.getDuas();
});

class DuasModernPage extends ConsumerStatefulWidget {
  const DuasModernPage({super.key});

  @override
  ConsumerState<DuasModernPage> createState() => _DuasModernPageState();
}

class _DuasModernPageState extends ConsumerState<DuasModernPage> {
  DuaModel? _selectedDua;
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final duasAsync = ref.watch(duasModernProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Douas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Toutes')),
              const PopupMenuItem(value: 'hajj', child: Text('Hajj')),
              const PopupMenuItem(value: 'daily', child: Text('Quotidiennes')),
              const PopupMenuItem(value: 'special', child: Text('Spéciales')),
            ],
          ),
        ],
      ),
      body: duasAsync.when(
        data: (duas) {
          final filteredDuas = _filterDuas(duas);
          
          if (filteredDuas.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: _buildDuasList(filteredDuas),
              ),
              if (_selectedDua != null)
                DuaPlayer(
                  dua: _selectedDua!,
                  onClose: () => setState(() => _selectedDua = null),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorWidget(error.toString()),
      ),
    );
  }

  List<DuaModel> _filterDuas(List<DuaModel> duas) {
    var filtered = duas;

    // Filtre par type
    if (_filterType != 'all') {
      filtered = filtered.where((d) => d.type.name == _filterType).toList();
    }

    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
          d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.arabicText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.translation.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  Widget _buildDuasList(List<DuaModel> duas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final dua = duas[index];
        final isSelected = _selectedDua?.id == dua.id;

        return DuaCard(
          dua: dua,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedDua = isSelected ? null : dua;
            });
          },
          onFavorite: () => _toggleFavorite(dua),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune dua trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _filterType = 'all';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(duasModernProvider),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher une dua'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Entrez un mot-clé...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.of(context).pop();
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(DuaModel dua) {
    // TODO: Implémenter la sauvegarde des favoris
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dua.isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}



