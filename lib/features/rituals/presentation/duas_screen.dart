import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// class DuasScreen extends StatefulWidget {
//   const DuasScreen({super.key});

//   @override
//   State<DuasScreen> createState() => _DuasScreenState();
// }

// class _DuasScreenState extends State<DuasScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
//           onPressed: () => context.pop(),
//         ),
//         title: const Text(
//           'My Duas',
//           style: TextStyle(
//             color: Color(0xFF1D3557),
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           _buildDuasSection(
//             title: 'Dua for Entering Ihram',
//             subtitle: 'Labbaik Allahumma labbaik...',
//             isPlaying: false,
//             onPlayPause: () {
//               // TODO: Implement audio playback
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Audio playback coming soon')),
//               );
//             },
//             color: const Color(0xFF2A9D8F),
//           ),
//           const SizedBox(height: 16),
//           _buildDuasSection(
//             title: 'Dua for Tawaf',
//             subtitle: 'Subhan Allah, Alhamdulillah...',
//             isPlaying: false,
//             onPlayPause: () {
//               // TODO: Implement audio playback
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Audio playback coming soon')),
//               );
//             },
//             color: const Color(0xFFE9C46A),
//           ),
//           const SizedBox(height: 16),
//           _buildDuasSection(
//             title: 'Dua for Sa\'i',
//             subtitle: 'Inna al-safa wa al-marwata...',
//             isPlaying: false,
//             onPlayPause: () {
//               // TODO: Implement audio playback
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Audio playback coming soon')),
//               );
//             },
//             color: const Color(0xFFF4A261),
//           ),
//           const SizedBox(height: 16),
//           _buildDuasSection(
//             title: 'Dua for Arafat',
//             subtitle: 'La ilaha illa Allah wahdahu...',
//             isPlaying: false,
//             onPlayPause: () {
//               // TODO: Implement audio playback
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Audio playback coming soon')),
//               );
//             },
//             color: const Color(0xFFE76F51),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDuasSection({
//     required String title,
//     required String subtitle,
//     required bool isPlaying,
//     required VoidCallback onPlayPause,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1D3557),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: 0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: color,
//                     size: 20,
//                   ),
//                   onPressed: onPlayPause,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: LinearProgressIndicator(
//                   value: 0.3,
//                   backgroundColor: Colors.grey[200],
//                   valueColor: AlwaysStoppedAnimation<Color>(color),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 '1:45 / 3:20',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  bool isPlayingArafah = false;
  bool isPlayingMina = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3557)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Duas',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDuasSection(
              title: 'Day of Arafah',
              subtitle: 'Special prayers for the most blessed day',
              isPlaying: isPlayingArafah,
              onPlayPause: () {
                setState(() {
                  isPlayingArafah = !isPlayingArafah;
                  if (isPlayingArafah) isPlayingMina = false;
                });
              },
              color: const Color(0xFF4FC3F7),
            ),
            const SizedBox(height: 20),
            _buildDuasSection(
              title: 'Mina',
              subtitle: 'Prayers during the days of Mina',
              isPlaying: isPlayingMina,
              onPlayPause: () {
                setState(() {
                  isPlayingMina = !isPlayingMina;
                  if (isPlayingMina) isPlayingArafah = false;
                });
              },
              color: const Color(0xFF2A9D8F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuasSection({
    required String title,
    required String subtitle,
    required bool isPlaying,
    required VoidCallback onPlayPause,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite_border,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3557),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'In the name of Allah, the Most Gracious, the Most Merciful',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (isPlaying) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
