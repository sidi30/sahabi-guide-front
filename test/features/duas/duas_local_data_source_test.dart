import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/core/services/notification_service.dart';
import 'package:sahabi_guide/shared/models/dua_model.dart';

/// Le corpus embarqué est la seule source hors ligne de la dua du jour : s'il
/// ne se parse pas, la rotation ne renvoie jamais rien. On le lit ici depuis le
/// disque (même contenu que l'asset chargé par `DuasLocalDataSourceImpl`).
List<DuaModel> _bundledDuas() {
  final raw = File('assets/data/duas.json').readAsStringSync();
  final decoded = json.decode(raw);
  final list =
      decoded is Map<String, dynamic> ? decoded['duas'] as List : decoded as List;
  return list.map((e) => DuaModel.fromJson(e)).toList();
}

void main() {
  group('Corpus de duas embarqué', () {
    test('se parse en DuaModel', () {
      final duas = _bundledDuas();
      expect(duas, isNotEmpty);
      expect(duas.every((d) => d.id.isNotEmpty), isTrue);
      expect(duas.every((d) => d.title.isNotEmpty), isTrue);
    });

    test('alimente la rotation de la dua du jour', () {
      final duas = _bundledDuas();
      final picked = NotificationService.duaOfTheDay(
        duas,
        day: DateTime(2026, 7, 29),
      );
      expect(picked, isNotNull);
      expect(picked!.isActive, isTrue);
    });
  });
}
