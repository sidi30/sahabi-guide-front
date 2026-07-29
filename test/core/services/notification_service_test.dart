import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/services/notification_service.dart';
import 'package:sahabi_guide/shared/models/dua_model.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

DuaModel _dua(String id, {DuaType type = DuaType.daily, bool active = true}) =>
    DuaModel(
      id: id,
      title: 'Dua $id',
      description: '',
      arabicText: '',
      transliteration: '',
      translation: '',
      type: type,
      audioPath: '',
      isActive: active,
    );

void main() {
  group('Dua du jour — rotation déterministe', () {
    final duas = [
      _dua('c'),
      _dua('a'),
      _dua('b'),
    ];

    test('le même jour donne la même dua', () {
      final day = DateTime(2026, 7, 29);
      final first = NotificationService.duaOfTheDay(duas, day: day);
      final second = NotificationService.duaOfTheDay(duas, day: day);
      expect(first, isNotNull);
      expect(second!.id, first!.id);
    });

    test('l\'ordre de la liste source ne change pas le résultat', () {
      final day = DateTime(2026, 7, 29);
      final expected = NotificationService.duaOfTheDay(duas, day: day)!.id;
      final shuffled = [_dua('b'), _dua('c'), _dua('a')];
      expect(NotificationService.duaOfTheDay(shuffled, day: day)!.id, expected);
    });

    test('le lendemain donne la dua suivante', () {
      final day = DateTime(2026, 7, 29);
      final sortedIds = ['a', 'b', 'c'];
      final todayId = NotificationService.duaOfTheDay(duas, day: day)!.id;
      final tomorrowId = NotificationService.duaOfTheDay(
        duas,
        day: day.add(const Duration(days: 1)),
      )!.id;
      final next = sortedIds[(sortedIds.indexOf(todayId) + 1) % 3];
      expect(tomorrowId, next);
    });

    test('boucle sur le nombre de duas', () {
      final day = DateTime(2026, 7, 29);
      final seen = <String>[];
      for (var i = 0; i < duas.length; i++) {
        seen.add(NotificationService.duaOfTheDay(
          duas,
          day: day.add(Duration(days: i)),
        )!.id);
      }
      expect(seen.toSet().length, duas.length, reason: 'toutes vues une fois');
      expect(
        NotificationService.duaOfTheDay(
          duas,
          day: day.add(Duration(days: duas.length)),
        )!.id,
        seen.first,
      );
    });

    test('l\'heure de la journée n\'influe pas', () {
      final morning = DateTime(2026, 7, 29, 0, 5);
      final evening = DateTime(2026, 7, 29, 23, 55);
      expect(
        NotificationService.duaOfTheDay(duas, day: evening)!.id,
        NotificationService.duaOfTheDay(duas, day: morning)!.id,
      );
    });

    test('ignore les duas inactives', () {
      final pool = [_dua('a', active: false), _dua('b')];
      for (var i = 0; i < 5; i++) {
        final picked = NotificationService.duaOfTheDay(
          pool,
          day: DateTime(2026, 7, 29).add(Duration(days: i)),
        );
        expect(picked!.id, 'b');
      }
    });

    test('retombe sur les autres types quand aucune dua quotidienne', () {
      final pool = [_dua('h1', type: DuaType.hajj)];
      expect(NotificationService.duaOfTheDay(pool)!.id, 'h1');
    });

    test('retourne null sur un corpus vide', () {
      expect(NotificationService.duaOfTheDay(const []), isNull);
      expect(
        NotificationService.duaOfTheDay([_dua('a', active: false)]),
        isNull,
      );
    });
  });

  group('NotificationIds — plages réservées', () {
    /// Bornes déclarées : chaque domaine occupe `[start, end[`.
    final ranges = <String, List<int>>{
      'ritual_main': [
        NotificationIds.ritualMainStart,
        NotificationIds.ritualMainEnd
      ],
      'ritual_reminder': [
        NotificationIds.ritualReminderStart,
        NotificationIds.ritualReminderEnd
      ],
      'ritual_overdue': [
        NotificationIds.ritualOverdueStart,
        NotificationIds.ritualOverdueEnd
      ],
      'prayer': [NotificationIds.prayerStart, NotificationIds.prayerEnd],
      'dua': [NotificationIds.duaStart, NotificationIds.duaEnd],
      'bot': [NotificationIds.botStart, NotificationIds.botEnd],
      'smart': [
        NotificationIds.smartReminderStart,
        NotificationIds.smartReminderEnd
      ],
    };

    test('aucune plage ne chevauche une autre', () {
      final entries = ranges.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        for (var j = i + 1; j < entries.length; j++) {
          final a = entries[i];
          final b = entries[j];
          final overlap = a.value[0] < b.value[1] && b.value[0] < a.value[1];
          expect(overlap, isFalse,
              reason: '${a.key} chevauche ${b.key}');
        }
      }
    });

    test('les ids de la dua du jour restent dans la plage duas', () {
      for (final id in [
        NotificationIds.duaOfTheDayMorning,
        NotificationIds.duaOfTheDayEvening,
      ]) {
        expect(id, greaterThanOrEqualTo(NotificationIds.duaStart));
        expect(id, lessThan(NotificationIds.duaEnd));
      }
      expect(NotificationIds.duaOfTheDayMorning,
          isNot(NotificationIds.duaOfTheDayEvening));
      // Et jamais dans la plage des prières, que l'ancien code écrasait.
      expect(NotificationIds.duaOfTheDayMorning,
          greaterThanOrEqualTo(NotificationIds.prayerEnd));
    });

    test('les ids de rituels restent bornés quel que soit l\'ordre', () {
      for (final order in [0, 7, 999, 1000, 5000, -3]) {
        expect(NotificationIds.ritualMain(order),
            inInclusiveRange(
                NotificationIds.ritualMainStart,
                NotificationIds.ritualMainEnd - 1));
        expect(NotificationIds.ritualReminder(order),
            inInclusiveRange(
                NotificationIds.ritualReminderStart,
                NotificationIds.ritualReminderEnd - 1));
        expect(NotificationIds.ritualOverdue(order),
            inInclusiveRange(
                NotificationIds.ritualOverdueStart,
                NotificationIds.ritualOverdueEnd - 1));
      }
    });

    test('stableId est déterministe, borné et tient dans un int32', () {
      const start = NotificationIds.duaImmediateStart;
      const end = NotificationIds.duaImmediateEnd;
      for (final key in ['dua:morning_dua', 'dua:zamzam_dua', 'dua:é🕋']) {
        final id = NotificationIds.stableId(key, start: start, end: end);
        expect(id, NotificationIds.stableId(key, start: start, end: end));
        expect(id, inInclusiveRange(start, end - 1));
        expect(id, lessThan(2147483647));
      }
    });
  });

  group('Fuseau horaire local', () {
    setUpAll(tz_data.initializeTimeZones);

    test('UTC+1 sans heure d\'été → Africa/Niamey (et pas Europe/Paris)', () {
      final zone = NotificationService.resolveLocalLocation(
        standardOffset: const Duration(hours: 1),
        observesDst: false,
      );
      expect(zone.name, 'Africa/Niamey');
    });

    test('UTC+1 avec heure d\'été → Europe/Paris', () {
      final zone = NotificationService.resolveLocalLocation(
        standardOffset: const Duration(hours: 1),
        observesDst: true,
      );
      expect(zone.name, 'Europe/Paris');
    });

    test('UTC+3 sans heure d\'été → Asia/Riyadh', () {
      final zone = NotificationService.resolveLocalLocation(
        standardOffset: const Duration(hours: 3),
        observesDst: false,
      );
      expect(zone.name, 'Asia/Riyadh');
    });

    test('offset inconnu : repli sur une zone au bon décalage, pas UTC', () {
      final zone = NotificationService.resolveLocalLocation(
        standardOffset: const Duration(hours: 7),
        observesDst: false,
      );
      final january = DateTime.utc(DateTime.now().year, 1, 15);
      expect(zone.timeZone(january.millisecondsSinceEpoch).offset,
          const Duration(hours: 7).inMilliseconds);
    });
  });
}
