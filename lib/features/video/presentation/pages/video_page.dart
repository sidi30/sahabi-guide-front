import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/video_service.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with SingleTickerProviderStateMixin {
  final VideoService _videoService = sl<VideoService>();
  late TabController _tabController;
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String _searchQuery = '';

  static const List<String> _categories = [
    'Tout',
    'preparatifs',
    'rituels',
    'preches',
    'temoignages',
    'conseils',
  ];

  static const Map<String, String> _categoryLabels = {
    'Tout': 'Tout',
    'preparatifs': 'Preparation',
    'rituels': 'Rituels',
    'preches': 'Preches',
    'temoignages': 'Temoignages',
    'conseils': 'Conseils',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final category = _categories[_tabController.index];
    setState(() {
      _selectedCategory = category == 'Tout' ? null : category;
    });
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoading = true);
    final videos = await _videoService.getActiveVideos(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredVideos {
    if (_searchQuery.isEmpty) return _videos;
    final query = _searchQuery.toLowerCase();
    return _videos.where((v) {
      final title = (v['title'] ?? '').toString().toLowerCase();
      final desc = (v['description'] ?? '').toString().toLowerCase();
      final tags = (v['tags'] ?? '').toString().toLowerCase();
      return title.contains(query) || desc.contains(query) || tags.contains(query);
    }).toList();
  }

  Future<void> _openVideo(Map<String, dynamic> video) async {
    final youtubeUrl = video['youtubeUrl'] as String?;
    final youtubeId = video['youtubeId'] as String?;
    final videoId = video['id'] as String?;

    if (youtubeUrl == null && youtubeId == null) return;

    // Track view
    if (videoId != null) {
      _videoService.trackView(videoId);
    }

    // Try native YouTube app first
    final url = youtubeId != null
        ? 'https://www.youtube.com/watch?v=$youtubeId'
        : youtubeUrl!;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatViews(int? count) {
    if (count == null || count == 0) return '';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k vues';
    return '$count vues';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos & Conseils'),
        backgroundColor: context.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((c) => Tab(text: _categoryLabels[c] ?? c)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une video...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Video list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVideos,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredVideos.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filteredVideos.length,
                          itemBuilder: (context, index) => _buildVideoCard(_filteredVideos[index]),
                        ),
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
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune video disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'De nouvelles videos arrivent bientot !',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final youtubeId = video['youtubeId'] as String?;
    final thumbnailUrl = youtubeId != null
        ? 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg'
        : null;
    final duration = _formatDuration(video['durationSeconds'] as int?);
    final views = _formatViews(video['viewCount'] as int?);
    final pilgrimageType = video['pilgrimageType'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openVideo(video),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.video_library, size: 48),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library, size: 48),
                        ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                    ),
                  ),
                ),
                // Duration badge
                if (duration.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                // Hajj/Omra badge
                if (pilgrimageType != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pilgrimageType == 'HAJJ' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pilgrimageType == 'HAJJ' ? 'Hajj' : 'Omra',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (video['description'] != null && (video['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      video['description'],
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (video['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _categoryLabels[video['category']] ?? video['category'],
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          ),
                        ),
                      const Spacer(),
                      if (views.isNotEmpty) ...[
                        Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(views, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
