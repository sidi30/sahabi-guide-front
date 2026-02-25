import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/shared/models/ritual_model.dart';

void main() {
  const testRitual = RitualModel(
    id: 'ritual-1',
    name: 'Ihram',
    order: 1,
    description: 'Entering the state of Ihram',
    type: RitualType.hajj,
    status: RitualStatus.pending,
    audioPaths: ['/audio/ihram.mp3'],
    audioSources: {'en': '/audio/en/ihram.mp3', 'fr': '/audio/fr/ihram.mp3'},
    videoSources: {'en': '/video/en/ihram.mp4'},
    steps: ['Step 1', 'Step 2'],
    translations: {'fr': 'Ihram FR', 'en': 'Ihram EN'},
    tags: ['hajj', 'required'],
    isActive: true,
    nextRitualId: 'ritual-2',
    contentVersion: 1,
  );

  group('RitualModel.fromJson', () {
    test('creates RitualModel from complete JSON', () {
      final json = {
        'id': 'ritual-1',
        'name': 'Ihram',
        'order': 1,
        'description': 'Entering the state of Ihram',
        'type': 'hajj',
        'status': 'pending',
        'audioPaths': ['/audio/ihram.mp3'],
        'steps': ['Step 1', 'Step 2'],
        'translations': {'fr': 'Ihram FR'},
        'tags': ['hajj'],
        'isActive': true,
        'nextRitualId': 'ritual-2',
        'contentVersion': 1,
      };

      final ritual = RitualModel.fromJson(json);
      expect(ritual.id, 'ritual-1');
      expect(ritual.name, 'Ihram');
      expect(ritual.order, 1);
      expect(ritual.type, RitualType.hajj);
      expect(ritual.status, RitualStatus.pending);
      expect(ritual.audioPaths, ['/audio/ihram.mp3']);
      expect(ritual.steps, ['Step 1', 'Step 2']);
      expect(ritual.translations['fr'], 'Ihram FR');
      expect(ritual.tags, ['hajj']);
      expect(ritual.isActive, true);
      expect(ritual.nextRitualId, 'ritual-2');
      expect(ritual.contentVersion, 1);
    });

    test('parses audioPaths as Map (language-keyed)', () {
      final json = {
        'id': 'r1',
        'name': 'Test',
        'order': 1,
        'description': 'desc',
        'audioPaths': {
          'en': '/audio/en/test.mp3',
          'fr': '/audio/fr/test.mp3',
        },
      };

      final ritual = RitualModel.fromJson(json);
      expect(ritual.audioSources['en'], '/audio/en/test.mp3');
      expect(ritual.audioSources['fr'], '/audio/fr/test.mp3');
      expect(ritual.audioPaths, isEmpty); // legacy list is empty when Map
    });

    test('parses audioPaths as List (legacy format)', () {
      final json = {
        'id': 'r1',
        'name': 'Test',
        'order': 1,
        'description': 'desc',
        'audioPaths': ['/audio/test1.mp3', '/audio/test2.mp3'],
      };

      final ritual = RitualModel.fromJson(json);
      expect(ritual.audioPaths, ['/audio/test1.mp3', '/audio/test2.mp3']);
      expect(ritual.audioSources, isEmpty);
    });

    test('parses all RitualType values', () {
      for (final type in ['hajj', 'umrah', 'daily', 'special']) {
        final json = {
          'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
          'type': type,
        };
        final ritual = RitualModel.fromJson(json);
        expect(ritual.type.name, type);
      }
    });

    test('defaults to hajj for unknown type', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'type': 'unknown',
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.type, RitualType.hajj);
    });

    test('parses all RitualStatus values', () {
      for (final status in ['pending', 'active', 'completed', 'overdue']) {
        final json = {
          'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
          'status': status,
        };
        final ritual = RitualModel.fromJson(json);
        expect(ritual.status.name, status);
      }
    });

    test('defaults to pending for unknown status', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'status': 'unknown',
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.status, RitualStatus.pending);
    });

    test('parses scheduledTime and completedAt', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'scheduledTime': '2025-06-15T08:00:00.000Z',
        'completedAt': '2025-06-15T09:30:00.000Z',
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.scheduledTime, isNotNull);
      expect(ritual.completedAt, isNotNull);
    });

    test('parses estimatedDuration in minutes', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'estimatedDuration': 45,
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.estimatedDuration, const Duration(minutes: 45));
    });

    test('uses stepsList as fallback for steps', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'stepsList': ['A', 'B'],
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.steps, ['A', 'B']);
    });

    test('parses videoPaths as videoSources', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'videoPaths': {'en': '/video/en/test.mp4'},
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.videoSources['en'], '/video/en/test.mp4');
    });

    test('resolves videoPath from videoSources', () {
      final json = {
        'id': 'r1', 'name': 'n', 'order': 1, 'description': 'd',
        'videoPaths': {'en': '/video/en/test.mp4'},
      };
      final ritual = RitualModel.fromJson(json);
      expect(ritual.videoPath, '/video/en/test.mp4');
    });
  });

  group('RitualModel.toJson', () {
    test('serializes all fields', () {
      final json = testRitual.toJson();
      expect(json['id'], 'ritual-1');
      expect(json['name'], 'Ihram');
      expect(json['order'], 1);
      expect(json['type'], 'hajj');
      expect(json['status'], 'pending');
      expect(json['steps'], ['Step 1', 'Step 2']);
      expect(json['tags'], ['hajj', 'required']);
      expect(json['isActive'], true);
      expect(json['nextRitualId'], 'ritual-2');
      expect(json['contentVersion'], 1);
    });

    test('serializes null optional fields', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
      );
      final json = ritual.toJson();
      expect(json['scheduledTime'], isNull);
      expect(json['completedAt'], isNull);
      expect(json['estimatedDuration'], isNull);
      expect(json['videoPath'], isNull);
      expect(json['nextRitualId'], isNull);
      expect(json['previousRitualId'], isNull);
    });
  });

  group('RitualModel.copyWith', () {
    test('copies with no changes', () {
      final copy = testRitual.copyWith();
      expect(copy.id, testRitual.id);
      expect(copy.name, testRitual.name);
      expect(copy.order, testRitual.order);
    });

    test('overrides specified fields', () {
      final copy = testRitual.copyWith(
        name: 'Tawaf',
        status: RitualStatus.completed,
      );
      expect(copy.name, 'Tawaf');
      expect(copy.status, RitualStatus.completed);
      expect(copy.id, testRitual.id); // unchanged
    });
  });

  group('RitualModel status helpers', () {
    test('isCompleted returns true for completed status', () {
      final ritual = testRitual.copyWith(status: RitualStatus.completed);
      expect(ritual.isCompleted, isTrue);
      expect(ritual.isPending, isFalse);
      expect(ritual.isOverdue, isFalse);
    });

    test('isPending returns true for pending status', () {
      expect(testRitual.isPending, isTrue);
      expect(testRitual.isCompleted, isFalse);
    });

    test('isOverdue returns true for overdue status', () {
      final ritual = testRitual.copyWith(status: RitualStatus.overdue);
      expect(ritual.isOverdue, isTrue);
    });
  });

  group('RitualModel.getTranslation', () {
    test('returns translation for existing language', () {
      expect(testRitual.getTranslation('fr'), 'Ihram FR');
      expect(testRitual.getTranslation('en'), 'Ihram EN');
    });

    test('falls back to name for missing language', () {
      expect(testRitual.getTranslation('ha'), 'Ihram');
    });
  });

  group('RitualModel.hasAudio', () {
    test('returns true when audioSources has values', () {
      expect(testRitual.hasAudio, isTrue);
    });

    test('returns true when audioPaths has values', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
        audioPaths: ['/audio/test.mp3'],
      );
      expect(ritual.hasAudio, isTrue);
    });

    test('returns false when no audio', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
      );
      expect(ritual.hasAudio, isFalse);
    });
  });

  group('RitualModel.hasVideo', () {
    test('returns true when videoSources has values', () {
      expect(testRitual.hasVideo, isTrue);
    });

    test('returns true when videoPath is set', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
        videoPath: '/video/test.mp4',
      );
      expect(ritual.hasVideo, isTrue);
    });

    test('returns false when no video', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
      );
      expect(ritual.hasVideo, isFalse);
    });
  });

  group('RitualModel.getAudioPath', () {
    test('returns audio for requested language', () {
      expect(testRitual.getAudioPath('en'), '/audio/en/ihram.mp3');
      expect(testRitual.getAudioPath('fr'), '/audio/fr/ihram.mp3');
    });

    test('falls back to English then legacy audioPaths', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
        audioSources: {'en': '/audio/en/test.mp3'},
        audioPaths: ['/audio/legacy.mp3'],
      );
      // Request Hausa -> falls back to en
      expect(ritual.getAudioPath('ha'), '/audio/en/test.mp3');
    });

    test('returns legacy audioPaths[0] when no audioSources match', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
        audioPaths: ['/audio/legacy.mp3'],
      );
      expect(ritual.getAudioPath('xx'), '/audio/legacy.mp3');
    });

    test('returns null when no audio available', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
      );
      expect(ritual.getAudioPath('en'), isNull);
    });
  });

  group('RitualModel.getVideoUrl', () {
    test('returns video for requested language', () {
      expect(testRitual.getVideoUrl('en'), '/video/en/ihram.mp4');
    });

    test('falls back to videoPath for missing language', () {
      const ritual = RitualModel(
        id: 'r1', name: 'n', order: 1, description: 'd',
        videoPath: '/video/default.mp4',
      );
      expect(ritual.getVideoUrl('ha'), '/video/default.mp4');
    });
  });

  group('RitualModel.getStatusColor', () {
    test('returns green for completed', () {
      final ritual = testRitual.copyWith(status: RitualStatus.completed);
      expect(ritual.getStatusColor(), Colors.green);
    });

    test('returns blue for active', () {
      final ritual = testRitual.copyWith(status: RitualStatus.active);
      expect(ritual.getStatusColor(), Colors.blue);
    });

    test('returns red for overdue', () {
      final ritual = testRitual.copyWith(status: RitualStatus.overdue);
      expect(ritual.getStatusColor(), Colors.red);
    });

    test('returns grey for pending', () {
      expect(testRitual.getStatusColor(), Colors.grey);
    });
  });

  group('RitualModel.getStatusIcon', () {
    test('returns check_circle for completed', () {
      final ritual = testRitual.copyWith(status: RitualStatus.completed);
      expect(ritual.getStatusIcon(), Icons.check_circle);
    });

    test('returns access_time for active', () {
      final ritual = testRitual.copyWith(status: RitualStatus.active);
      expect(ritual.getStatusIcon(), Icons.access_time);
    });

    test('returns warning for overdue', () {
      final ritual = testRitual.copyWith(status: RitualStatus.overdue);
      expect(ritual.getStatusIcon(), Icons.warning);
    });

    test('returns circle_outlined for pending', () {
      expect(testRitual.getStatusIcon(), Icons.circle_outlined);
    });
  });

  group('RitualModel equality', () {
    test('rituals with same id, name, order, status are equal', () {
      const ritual1 = RitualModel(
        id: 'r1', name: 'Test', order: 1, description: 'desc1',
      );
      const ritual2 = RitualModel(
        id: 'r1', name: 'Test', order: 1, description: 'desc2',
      );
      expect(ritual1, equals(ritual2));
    });

    test('rituals with different ids are not equal', () {
      const ritual1 = RitualModel(
        id: 'r1', name: 'Test', order: 1, description: '',
      );
      const ritual2 = RitualModel(
        id: 'r2', name: 'Test', order: 1, description: '',
      );
      expect(ritual1, isNot(equals(ritual2)));
    });
  });

  group('RitualModel.toString', () {
    test('includes id, name, order, status', () {
      final str = testRitual.toString();
      expect(str, contains('ritual-1'));
      expect(str, contains('Ihram'));
      expect(str, contains('1'));
    });
  });
}
