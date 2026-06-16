import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/features/rituals/data/ritual_guidance.dart';

void main() {
  group('guidanceFor — mapping par nom (rituals_seed.json)', () {
    // (nom réel du seed) -> id de guide attendu
    const cases = <String, String>{
      "L'Ihram (L'État de Sacralisation)": 'ihram',
      "Tawaf al-Qudum (Tawaf d'Arrivée / Omra)": 'tawaf',
      "Le Sa'i (Marche entre Safa et Marwa)": 'sai',
      "Taqsir (Coupe des cheveux - Fin Omra)": 'halq',
      "Jour de Tarwiyah (8 Dhul-Hijjah)": 'mina',
      "Jour d'Arafat (9 Dhul-Hijjah)": 'arafat',
      "Nuit à Muzdalifah": 'muzdalifah',
      "Lapidation de Jamarat Al-Aqabah (10 Dhul-Hijjah)": 'ramy',
      "Le Sacrifice (Hady)": 'hady',
      "Halq ou Taqsir (Rasage ou Coupe)": 'halq',
      "Tawaf Al-Ifadah": 'tawaf_ifada',
      "Jours de Tashreeq (Mina & Lapidation)": 'mina_days',
      "Tawaf Al-Wada (Tawaf d'Adieu)": 'tawaf_wida',
    };

    cases.forEach((name, expectedId) {
      test('"$name" -> $expectedId', () {
        final g = guidanceFor('uuid-non-mappe', name);
        expect(g, isNotNull, reason: 'aucun guide pour "$name"');
        expect(g, same(kRitualGuidance[expectedId]),
            reason: '"$name" devrait pointer vers $expectedId');
      });
    });

    test('chaque guide a un contenu distinct sur les 4 axes', () {
      for (final entry in kRitualGuidance.entries) {
        final g = entry.value;
        expect(g.explanation.trim(), isNotEmpty, reason: entry.key);
        expect(g.importantSteps, isNotEmpty, reason: entry.key);
        expect(g.howTo, isNotEmpty, reason: entry.key);
        expect(g.security, isNotEmpty, reason: entry.key);
        expect(g.practicalTips, isNotEmpty, reason: entry.key);
      }
    });

    test('les explications ne sont pas toutes identiques (pas de duplication)',
        () {
      final explanations =
          kRitualGuidance.values.map((g) => g.explanation).toSet();
      expect(explanations.length, kRitualGuidance.length,
          reason: 'des explications sont dupliquées entre rituels');
    });

    test('toSpeech inclut les sections Étapes / Comment / Sécurité', () {
      final speech = kRitualGuidance['tawaf']!.toSpeech('Tawaf');
      expect(speech, contains('Étapes importantes'));
      expect(speech, contains('Comment'));
      expect(speech, contains('Sécurité'));
    });
  });
}
