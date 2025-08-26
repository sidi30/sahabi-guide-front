import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/dua_model.dart';
import '../providers/duas_provider.dart';

class DuasPage extends StatefulWidget {
  const DuasPage({super.key});

  @override
  State<DuasPage> createState() => _DuasPageState();
}

class _DuasPageState extends State<DuasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DuasProvider>().loadDuas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Duas',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline, color: Color(0xFF1D3557)),
            onPressed: () {
              // Show favorites
              setState(() {
                _selectedFilter = _selectedFilter == 'favorites' ? 'all' : 'favorites';
              });
            },
          ),
        ],
      ),
      body: Consumer<DuasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4FC3F7),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${provider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadDuas(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final duas = _selectedFilter == 'favorites' 
              ? provider.favoriteDuas 
              : provider.duas;

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.searchDuas,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une dua...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4FC3F7)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('Toutes', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Quotidien', 'daily'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Voyage', 'voyage'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Protection', 'protection'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Favoris', 'favorites'),
                  ],
                ),
              ),

              // Duas List
              Expanded(
                child: duas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFilter == 'favorites' 
                                  ? Icons.favorite_outline 
                                  : Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'favorites'
                                  ? 'Aucune dua favorite'
                                  : 'Aucune dua trouvée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: duas.length,
                        itemBuilder: (context, index) {
                          final dua = duas[index];
                          return _buildDuaCard(dua, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
        if (value == 'favorites') {
          context.read<DuasProvider>().loadFavoriteDuas();
        } else if (value != 'all') {
          context.read<DuasProvider>().searchDuas(value);
        } else {
          context.read<DuasProvider>().clearSearch();
        }
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4FC3F7),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1D3557),
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildDuaCard(DuaModel dua, DuasProvider provider) {
    final isFavorite = provider.isFavorite(dua.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showDuaDetail(context, dua, provider);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dua.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      provider.toggleFavorite(dua.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dua.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      dua.arabicText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3557),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dua.transliteration,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: dua.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF4FC3F7).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(0xFF4FC3F7),
                      fontWeight: FontWeight.w500,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDuaDetail(BuildContext context, DuaModel dua, DuasProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dua.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          provider.isFavorite(dua.id) 
                              ? Icons.favorite 
                              : Icons.favorite_outline,
                          color: provider.isFavorite(dua.id) 
                              ? Colors.red 
                              : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(dua.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dua.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Arabe',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dua.arabicText,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D3557),
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Translittération',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dua.transliteration,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1D3557),
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4FC3F7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Traduction',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dua.translation,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1D3557),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dua.audioPath != null) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Play audio
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lecture audio en cours...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Écouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
