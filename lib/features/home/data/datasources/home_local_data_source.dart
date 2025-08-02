import '../../../../core/utils/constants.dart';

abstract class HomeLocalDataSource {
  Future<List<Map<String, dynamic>>> getHomeMenuItems();
  Future<Map<String, dynamic>> getDashboardData();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<Map<String, dynamic>>> getHomeMenuItems() async {
    // Mock data for home menu items
    return [
      {
        'id': 'rituals',
        'title': 'Rituels',
        'subtitle': 'Prières et pratiques quotidiennes',
        'icon': 'schedule',
        'color': '#1D3557',
        'route': AppConstants.ritualsRoute,
      },
      {
        'id': 'duas',
        'title': 'Douas',
        'subtitle': 'Invocations et supplications',
        'icon': 'book',
        'color': '#2A9D8F',
        'route': '/duas',
      },
      {
        'id': 'map',
        'title': 'Carte',
        'subtitle': 'Mosquées et lieux saints',
        'icon': 'location_on',
        'color': '#E63946',
        'route': AppConstants.mapRoute,
      },
      {
        'id': 'health',
        'title': 'Santé',
        'subtitle': 'Profil médical et bien-être',
        'icon': 'health_and_safety',
        'color': '#F77F00',
        'route': AppConstants.healthRoute,
      },
      {
        'id': 'profile',
        'title': 'Profil',
        'subtitle': 'Informations personnelles',
        'icon': 'person',
        'color': '#6F2DBD',
        'route': AppConstants.profileRoute,
      },
      {
        'id': 'connectivity',
        'title': 'Internet',
        'subtitle': 'Connexion et synchronisation',
        'icon': 'wifi',
        'color': '#457B9D',
        'route': AppConstants.connectivityRoute,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock dashboard data
    return {
      'currentPrayer': {
        'name': 'Dhuhr',
        'time': '12:30',
        'remaining': '2h 15min',
      },
      'nextPrayer': {
        'name': 'Asr',
        'time': '15:45',
        'remaining': '5h 30min',
      },
      'todayStats': {
        'prayersCompleted': 3,
        'totalPrayers': 5,
        'duasRead': 7,
        'dhikrCount': 156,
      },
      'weeklyProgress': {
        'prayerCompletion': 85,
        'duaCompletion': 92,
        'dhikrGoal': 78,
      },
      'recentActivity': [
        {
          'type': 'prayer',
          'name': 'Fajr',
          'time': '05:30',
          'completed': true,
        },
        {
          'type': 'dua',
          'name': 'Dua du matin',
          'time': '06:00',
          'completed': true,
        },
        {
          'type': 'dhikr',
          'name': 'Tasbih',
          'time': '07:15',
          'completed': true,
        },
      ],
    };
  }
}
