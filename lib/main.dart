import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahabi_guide/features/splash/presentation/splash_page.dart';

// Routes de l'application
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String menu = '/menu';
  static const String timeline = '/timeline';
  static const String duas = '/duas';
  // Other routes to be implemented
  // static const String map = '/map';
  // static const String videos = '/videos';
  // static const String health = '/health';
  // static const String profile = '/profile';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        // Splash/Onboarding Screen
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Menu principal
        GoRoute(
          path: AppRoutes.menu,
          builder: (context, state) => const MenuScreen(),
        ),
        
        // Timeline Screen
        GoRoute(
          path: AppRoutes.timeline,
          builder: (context, state) =>  TimelineScreen(),
        ),
        
        // Duas Screen
        GoRoute(
          path: AppRoutes.duas,
          builder: (context, state) =>  DuasScreen(),
        ),
        
        // Other routes to be implemented
        /*
        GoRoute(
          path: AppRoutes.map,
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: AppRoutes.videos,
          builder: (context, state) => const VideosScreen(),
        ),
        GoRoute(
          path: AppRoutes.health,
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        */
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Hajj Companion',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        primaryColor: const Color(0xFF1D3557),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF2A9D8F),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF1D3557),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String selectedRole = '';
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A9D8F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Hajj Companion',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Your guide for a blessed and seamless pilgrimage.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'I am a...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildRoleButton(
                          icon: Icons.person,
                          title: 'Pilgrim',
                          isSelected: selectedRole == 'pilgrim',
                          onTap: () => setState(() => selectedRole = 'pilgrim'),
                        ),

                        const SizedBox(height: 12),

                        _buildRoleButton(
                          icon: Icons.people,
                          title: 'Guide',
                          isSelected: selectedRole == 'guide',
                          onTap: () => setState(() => selectedRole = 'guide'),
                        ),

                        const SizedBox(height: 30),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Language',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildLanguageButton(
                                icon: Icons.volume_up,
                                title: 'Hausa',
                                isSelected: selectedLanguage == 'hausa',
                                onTap: () => setState(() => selectedLanguage = 'hausa'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildLanguageButton(
                                icon: Icons.volume_up,
                                title: 'Djerma',
                                isSelected: selectedLanguage == 'djerma',
                                onTap: () => setState(() => selectedLanguage = 'djerma'),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: selectedRole.isNotEmpty && selectedLanguage.isNotEmpty
                                  ? () => context.push(AppRoutes.menu)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FC3F7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4FC3F7), width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1D3557) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hajj Guide',
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
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              icon: Icons.luggage,
              title: 'My Hajj',
              color: const Color(0xFF4FC3F7),
              onTap: () => context.push(AppRoutes.timeline),
            ),
            _buildMenuCard(
              icon: Icons.favorite_border,
              title: 'My Duas',
              color: const Color(0xFF4FC3F7),
              onTap: () => context.push(AppRoutes.duas),
            ),
            _buildMenuCard(
              icon: Icons.map_outlined,
              title: 'Map & Location',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de la carte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.play_circle_outline,
              title: 'Video\nPreparation',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran des vidéos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.favorite,
              title: 'My Health',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de santé
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
            _buildMenuCard(
              icon: Icons.account_circle_outlined,
              title: 'Profile &\nEmergency',
              color: const Color(0xFF4FC3F7),
              onTap: () {
                // TODO: Implémenter l'écran de profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité en cours de développement')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3557),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

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
          'My Hajj Timeline',
          style: TextStyle(
            color: Color(0xFF1D3557),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimelineItem('Ihram', 'Enter the sacred state', true),
          _buildTimelineItem(
              'Tawaf al-Qudum', 'Arrival circumambulation', true),
          _buildTimelineItem('Sa\'i', 'Walking between hills', false),
          _buildTimelineItem('Day of Tarwiyah', 'Proceed to Mina', false),
          _buildTimelineItem('Day of Arafah', 'Stand at Mount Arafah', false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String description, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF2A9D8F) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D3557),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: Colors.black.withOpacity(0.05),
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
                  color: color.withOpacity(0.1),
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
