import '../../../../shared/models/ritual_model.dart';

abstract class RitualsLocalDataSource {
  Future<List<RitualModel>> getRituals();
  Future<List<DuaModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
  Future<void> markRitualAsCompleted(String id);
  Future<void> updateRitual(RitualModel ritual);
}

class RitualsLocalDataSourceImpl implements RitualsLocalDataSource {
  @override
  Future<List<RitualModel>> getRituals() async {
    // Mock data for rituals - will be replaced by real data from API
    final now = DateTime.now();
    return [
      RitualModel(
        id: '1',
        code: 'FAJR',
        title: 'Prière du Fajr',
        order: 1,
        description: 'Prière de l\'aube, première prière de la journée',
        mediaRefs: ['audio/fajr.mp3'],
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '2',
        code: 'DHUHR',
        title: 'Prière du Dhuhr',
        order: 2,
        description: 'Prière de midi',
        mediaRefs: ['audio/dhuhr.mp3'],
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '3',
        code: 'ASR',
        title: 'Prière de l\'Asr',
        order: 3,
        description: 'Prière de l\'après-midi',
        mediaRefs: ['audio/asr.mp3'],
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '4',
        code: 'MAGHRIB',
        title: 'Prière du Maghrib',
        order: 4,
        description: 'Prière du coucher du soleil',
        mediaRefs: ['audio/maghrib.mp3'],
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '5',
        code: 'ISHA',
        title: 'Prière de l\'Isha',
        order: 5,
        description: 'Prière de la nuit',
        mediaRefs: ['audio/isha.mp3'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<DuaModel>> getDuas() async {
    final now = DateTime.now();
    return [
      DuaModel(
        id: 'dua1',
        title: 'Dua du matin',
        text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        audioUrl: 'assets/audio/duas/morning_dua.mp3',
        tags: ['matin', 'réveil'],
      ),
      DuaModel(
        id: 'dua2',
        title: 'Dua avant le repas',
        text: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
        audioUrl: 'assets/audio/duas/before_meal_dua.mp3',
        tags: ['repas', 'nourriture'],
      ),
      DuaModel(
        id: 'dua3',
        title: 'Dua après le repas',
        text: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        audioUrl: 'assets/audio/duas/after_meal_dua.mp3',
        tags: ['repas', 'remerciement'],
      ),
    ];
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    final rituals = await getRituals();
    try {
      return rituals.firstWhere((ritual) => ritual.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markRitualAsCompleted(String id) async {
    // In a real app, this would update the local database
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateRitual(RitualModel ritual) async {
    // In a real app, this would update the local database
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
