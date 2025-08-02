import '../../../../shared/models/ritual_model.dart';

abstract class RitualsLocalDataSource {
  Future<List<RitualModel>> getRituals();
  Future<List<RitualModel>> getDuas();
  Future<RitualModel?> getRitualById(String id);
  Future<void> markRitualAsCompleted(String id);
  Future<void> updateRitual(RitualModel ritual);
}

class RitualsLocalDataSourceImpl implements RitualsLocalDataSource {
  @override
  Future<List<RitualModel>> getRituals() async {
    // Mock data for rituals
    final now = DateTime.now();
    return [
      RitualModel(
        id: '1',
        title: 'Prière du Fajr',
        description: 'Prière de l\'aube, première prière de la journée',
        type: RitualType.prayer,
        frequency: RitualFrequency.daily,
        scheduledTime: DateTime(now.year, now.month, now.day, 5, 30),
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '2',
        title: 'Prière du Dhuhr',
        description: 'Prière de midi',
        type: RitualType.prayer,
        frequency: RitualFrequency.daily,
        scheduledTime: DateTime(now.year, now.month, now.day, 12, 30),
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '3',
        title: 'Prière de l\'Asr',
        description: 'Prière de l\'après-midi',
        type: RitualType.prayer,
        frequency: RitualFrequency.daily,
        scheduledTime: DateTime(now.year, now.month, now.day, 15, 45),
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '4',
        title: 'Prière du Maghrib',
        description: 'Prière du coucher du soleil',
        type: RitualType.prayer,
        frequency: RitualFrequency.daily,
        scheduledTime: DateTime(now.year, now.month, now.day, 18, 15),
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '5',
        title: 'Prière de l\'Isha',
        description: 'Prière de la nuit',
        type: RitualType.prayer,
        frequency: RitualFrequency.daily,
        scheduledTime: DateTime(now.year, now.month, now.day, 19, 45),
        priority: 5,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '6',
        title: 'Dhikr du matin',
        description: 'Invocations à réciter le matin',
        type: RitualType.dhikr,
        frequency: RitualFrequency.daily,
        duration: const Duration(minutes: 15),
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: '7',
        title: 'Dhikr du soir',
        description: 'Invocations à réciter le soir',
        type: RitualType.dhikr,
        frequency: RitualFrequency.daily,
        duration: const Duration(minutes: 15),
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<RitualModel>> getDuas() async {
    final now = DateTime.now();
    return [
      RitualModel(
        id: 'dua1',
        title: 'Dua du matin',
        description: 'Invocations à réciter au réveil',
        type: RitualType.dua,
        frequency: RitualFrequency.daily,
        arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        transliteration: 'Alhamdu lillahi alladhi ahyana ba\'da ma amatana wa ilayhi an-nushur',
        translation: 'Louange à Allah qui nous a redonné la vie après nous avoir fait mourir, et vers Lui est la résurrection.',
        audioPath: 'assets/audio/duas/morning_dua.mp3',
        duration: const Duration(minutes: 2),
        priority: 4,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: 'dua2',
        title: 'Dua avant le repas',
        description: 'Invocation avant de manger',
        type: RitualType.dua,
        frequency: RitualFrequency.daily,
        arabicText: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
        transliteration: 'Bismillahi wa \'ala barakati Allah',
        translation: 'Au nom d\'Allah et avec la bénédiction d\'Allah.',
        audioPath: 'assets/audio/duas/before_meal_dua.mp3',
        duration: const Duration(seconds: 30),
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: 'dua3',
        title: 'Dua après le repas',
        description: 'Invocation après avoir mangé',
        type: RitualType.dua,
        frequency: RitualFrequency.daily,
        arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
        transliteration: 'Alhamdu lillahi alladhi at\'amana wa saqana wa ja\'alana muslimin',
        translation: 'Louange à Allah qui nous a nourris, nous a abreuvés et a fait de nous des musulmans.',
        audioPath: 'assets/audio/duas/after_meal_dua.mp3',
        duration: const Duration(seconds: 45),
        priority: 2,
        createdAt: now,
        updatedAt: now,
      ),
      RitualModel(
        id: 'dua4',
        title: 'Dua du voyage',
        description: 'Invocation pour le voyage',
        type: RitualType.dua,
        frequency: RitualFrequency.occasional,
        arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
        transliteration: 'Subhana alladhi sakhkhara lana hadha wa ma kunna lahu muqrinin wa inna ila rabbina lamunqalibun',
        translation: 'Gloire à Celui qui a mis ceci à notre service alors que nous n\'étions pas capables de les dominer. Et c\'est vers notre Seigneur que nous retournerons.',
        audioPath: 'assets/audio/duas/travel_dua.mp3',
        duration: const Duration(minutes: 1),
        priority: 3,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<RitualModel?> getRitualById(String id) async {
    final rituals = await getRituals();
    final duas = await getDuas();
    final allRituals = [...rituals, ...duas];
    
    try {
      return allRituals.firstWhere((ritual) => ritual.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markRitualAsCompleted(String id) async {
    // In a real app, this would update the local database
    // For now, we'll just simulate the operation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateRitual(RitualModel ritual) async {
    // In a real app, this would update the local database
    // For now, we'll just simulate the operation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
