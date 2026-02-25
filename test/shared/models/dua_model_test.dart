import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/shared/models/dua_model.dart';

void main() {
  const testDua = DuaModel(
    id: '1',
    title: 'Test Dua',
    description: 'A test dua',
    arabicText: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    translation: 'Au nom de Dieu',
    type: DuaType.daily,
    audioPath: '/audio/test.mp3',
    duration: Duration(seconds: 30),
    priority: 1,
    tags: ['morning', 'daily'],
    isActive: true,
    isFavorite: false,
    translations: {'fr': 'Au nom de Dieu', 'en': 'In the name of God'},
    audioPaths: {'fr': '/audio/fr/test.mp3', 'en': '/audio/en/test.mp3'},
    ritualId: 'ritual-1',
    playCount: 5,
  );

  group('DuaModel.fromJson', () {
    test('creates DuaModel from complete JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Dua',
        'description': 'A test dua',
        'arabicText': 'بِسْمِ اللَّهِ',
        'transliteration': 'Bismillah',
        'translation': 'Au nom de Dieu',
        'type': 'daily',
        'audioPath': '/audio/test.mp3',
        'duration': 30,
        'priority': 1,
        'tags': ['morning'],
        'isActive': true,
        'isFavorite': true,
        'ritualId': 'ritual-1',
        'playCount': 3,
      };

      final dua = DuaModel.fromJson(json);
      expect(dua.id, '1');
      expect(dua.title, 'Test Dua');
      expect(dua.arabicText, 'بِسْمِ اللَّهِ');
      expect(dua.type, DuaType.daily);
      expect(dua.duration, const Duration(seconds: 30));
      expect(dua.priority, 1);
      expect(dua.isActive, true);
      expect(dua.isFavorite, true);
      expect(dua.ritualId, 'ritual-1');
      expect(dua.playCount, 3);
    });

    test('creates DuaModel from backend API format', () {
      final json = {
        'id': 42,
        'arabicText': 'بسم الله',
        'frenchTranslation': 'Au nom de Dieu',
        'englishTranslation': 'In the name of God',
        'audioUrl': '/audio/dua42.mp3',
        'ritualId': 5,
        'orderIndex': 3,
      };

      final dua = DuaModel.fromJson(json);
      expect(dua.id, '42');
      expect(dua.arabicText, 'بسم الله');
      expect(dua.translation, 'Au nom de Dieu');
      expect(dua.audioPath, '/audio/dua42.mp3');
      expect(dua.translations['fr'], 'Au nom de Dieu');
      expect(dua.translations['en'], 'In the name of God');
      expect(dua.translations['ar'], 'بسم الله');
      expect(dua.audioPaths['fr'], '/audio/dua42.mp3');
      expect(dua.priority, 3);
      expect(dua.ritualId, '5');
    });

    test('handles missing/null fields with defaults', () {
      final json = <String, dynamic>{};
      final dua = DuaModel.fromJson(json);
      expect(dua.id, '');
      expect(dua.arabicText, '');
      expect(dua.translation, '');
      expect(dua.type, DuaType.daily);
      expect(dua.priority, 1);
      expect(dua.isActive, true);
      expect(dua.isFavorite, false);
      expect(dua.playCount, 0);
    });

    test('parses all DuaType values', () {
      for (final type in ['hajj', 'umrah', 'daily', 'special', 'protection', 'gratitude']) {
        final json = {'type': type};
        final dua = DuaModel.fromJson(json);
        expect(dua.type.name, type);
      }
    });

    test('defaults to daily for unknown type', () {
      final json = {'type': 'unknown'};
      final dua = DuaModel.fromJson(json);
      expect(dua.type, DuaType.daily);
    });

    test('defaults to daily for null type', () {
      final json = {'type': null};
      final dua = DuaModel.fromJson(json);
      expect(dua.type, DuaType.daily);
    });

    test('parses lastPlayedAt date', () {
      final json = {
        'lastPlayedAt': '2025-01-15T10:30:00.000Z',
      };
      final dua = DuaModel.fromJson(json);
      expect(dua.lastPlayedAt, isNotNull);
      expect(dua.lastPlayedAt!.year, 2025);
    });

    test('uses text field as fallback for arabicText', () {
      final json = {'text': 'fallback text'};
      final dua = DuaModel.fromJson(json);
      expect(dua.arabicText, 'fallback text');
    });

    test('merges extra translations from JSON', () {
      final json = {
        'frenchTranslation': 'Français',
        'translations': {'ha': 'Hausa translation'},
      };
      final dua = DuaModel.fromJson(json);
      expect(dua.translations['fr'], 'Français');
      expect(dua.translations['ha'], 'Hausa translation');
    });
  });

  group('DuaModel.toJson', () {
    test('serializes all fields', () {
      final json = testDua.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Test Dua');
      expect(json['arabicText'], 'بِسْمِ اللَّهِ');
      expect(json['type'], 'daily');
      expect(json['audioPath'], '/audio/test.mp3');
      expect(json['duration'], 30);
      expect(json['priority'], 1);
      expect(json['tags'], ['morning', 'daily']);
      expect(json['isActive'], true);
      expect(json['isFavorite'], false);
      expect(json['ritualId'], 'ritual-1');
      expect(json['playCount'], 5);
    });

    test('serializes null lastPlayedAt', () {
      final json = testDua.toJson();
      expect(json['lastPlayedAt'], isNull);
    });

    test('roundtrip fromJson/toJson preserves data', () {
      final json = testDua.toJson();
      final restored = DuaModel.fromJson(json);
      expect(restored.id, testDua.id);
      expect(restored.title, testDua.title);
      expect(restored.arabicText, testDua.arabicText);
      expect(restored.type, testDua.type);
      expect(restored.audioPath, testDua.audioPath);
    });
  });

  group('DuaModel.copyWith', () {
    test('copies with no changes', () {
      final copy = testDua.copyWith();
      expect(copy.id, testDua.id);
      expect(copy.title, testDua.title);
      expect(copy.type, testDua.type);
    });

    test('overrides specified fields', () {
      final copy = testDua.copyWith(
        title: 'New Title',
        isFavorite: true,
        playCount: 10,
      );
      expect(copy.title, 'New Title');
      expect(copy.isFavorite, true);
      expect(copy.playCount, 10);
      // Other fields unchanged
      expect(copy.id, testDua.id);
      expect(copy.arabicText, testDua.arabicText);
    });

    test('can change type', () {
      final copy = testDua.copyWith(type: DuaType.hajj);
      expect(copy.type, DuaType.hajj);
    });

    test('can change duration', () {
      final copy = testDua.copyWith(duration: const Duration(minutes: 5));
      expect(copy.duration, const Duration(minutes: 5));
    });
  });

  group('DuaModel.getTranslation', () {
    test('returns translation for existing language', () {
      expect(testDua.getTranslation('fr'), 'Au nom de Dieu');
      expect(testDua.getTranslation('en'), 'In the name of God');
    });

    test('returns default translation for missing language', () {
      expect(testDua.getTranslation('ha'), 'Au nom de Dieu');
    });
  });

  group('DuaModel.getAudioPath', () {
    test('returns audio path for existing language', () {
      expect(testDua.getAudioPath('fr'), '/audio/fr/test.mp3');
      expect(testDua.getAudioPath('en'), '/audio/en/test.mp3');
    });

    test('returns default audio path for missing language', () {
      expect(testDua.getAudioPath('ha'), '/audio/test.mp3');
    });
  });

  group('DuaModel.getFormattedDuration', () {
    test('formats seconds only', () {
      const dua = DuaModel(
        id: '1', title: 't', description: 'd',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '', duration: Duration(seconds: 45),
      );
      expect(dua.getFormattedDuration(), '45s');
    });

    test('formats minutes and seconds', () {
      const dua = DuaModel(
        id: '1', title: 't', description: 'd',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '', duration: Duration(minutes: 2, seconds: 15),
      );
      expect(dua.getFormattedDuration(), '2m 15s');
    });

    test('formats whole minutes', () {
      const dua = DuaModel(
        id: '1', title: 't', description: 'd',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '', duration: Duration(minutes: 3),
      );
      expect(dua.getFormattedDuration(), '3m 0s');
    });
  });

  group('DuaModel equality', () {
    test('two duas with same id, title, type are equal', () {
      const dua1 = DuaModel(
        id: '1', title: 'Test', description: 'desc1',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '', type: DuaType.daily,
      );
      const dua2 = DuaModel(
        id: '1', title: 'Test', description: 'desc2',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '', type: DuaType.daily,
      );
      expect(dua1, equals(dua2));
    });

    test('duas with different ids are not equal', () {
      const dua1 = DuaModel(
        id: '1', title: 'Test', description: '',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '',
      );
      const dua2 = DuaModel(
        id: '2', title: 'Test', description: '',
        arabicText: '', transliteration: '', translation: '',
        audioPath: '',
      );
      expect(dua1, isNot(equals(dua2)));
    });
  });

  group('DuaModel.getTypeColor', () {
    test('returns color for each type', () {
      for (final type in DuaType.values) {
        final dua = testDua.copyWith(type: type);
        expect(dua.getTypeColor(), isNotNull);
      }
    });
  });

  group('DuaModel.getTypeIcon', () {
    test('returns icon for each type', () {
      for (final type in DuaType.values) {
        final dua = testDua.copyWith(type: type);
        expect(dua.getTypeIcon(), isNotNull);
      }
    });
  });
}
