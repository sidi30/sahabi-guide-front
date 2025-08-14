import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Préparation Vidéo'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1D3557)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF1D3557),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4FC3F7),
            tabs: [
              Tab(text: 'Tout'),
              Tab(text: 'Rituels'),
              Tab(text: 'Conseils'),
              Tab(text: 'Enfants'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoList(context, _allVideos),
            _buildVideoList(context, _ritualVideos),
            _buildVideoList(context, _tipsVideos),
            _buildVideoList(context, _kidsVideos),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(BuildContext context, List<Map<String, String>> videos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(context, video);
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, String> video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder pour la vidéo
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(video['thumbnail']!), // Utilisation de l'URL de la vignette
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3557),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      video['duration']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${video['views']} vues',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Données de démonstration pour les vidéos
  static const List<Map<String, String>> _allVideos = [
    {
      'title': 'Guide complet du pèlerinage',
      'duration': '15:30',
      'views': '12.5K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
    {
      'title': 'Les étapes du Hajj',
      'duration': '8:45',
      'views': '8.2K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
  ];

  static const List<Map<String, String>> _ritualVideos = [
    {
      'title': 'Comment faire les tours autour de la Kaaba',
      'duration': '6:20',
      'views': '15.3K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
    {
      'title': 'La marche entre Safa et Marwa',
      'duration': '4:15',
      'views': '7.8K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
  ];

  static const List<Map<String, String>> _tipsVideos = [
    {
      'title': '10 conseils pour votre pèlerinage',
      'duration': '12:30',
      'views': '22.1K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
  ];

  static const List<Map<String, String>> _kidsVideos = [
    {
      'title': 'Le Hajj expliqué aux enfants',
      'duration': '5:45',
      'views': '5.2K',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
  ];
}
