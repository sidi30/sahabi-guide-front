import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/shared/utils/language_utils.dart';

void main() {
  group('LanguageUtils.normalize', () {
    test('returns default language for null input', () {
      expect(LanguageUtils.normalize(null), 'en');
    });

    test('returns default language for empty string', () {
      expect(LanguageUtils.normalize(''), 'en');
    });

    test('normalizes English codes', () {
      expect(LanguageUtils.normalize('en'), 'en');
      expect(LanguageUtils.normalize('EN'), 'en');
      expect(LanguageUtils.normalize('en-US'), 'en');
      expect(LanguageUtils.normalize('english'), 'en');
      expect(LanguageUtils.normalize('English'), 'en');
    });

    test('normalizes French codes', () {
      expect(LanguageUtils.normalize('fr'), 'fr');
      expect(LanguageUtils.normalize('FR'), 'fr');
      expect(LanguageUtils.normalize('fr-FR'), 'fr');
      expect(LanguageUtils.normalize('francais'), 'fr');
      expect(LanguageUtils.normalize('Français'), 'fr');
    });

    test('normalizes Arabic codes', () {
      expect(LanguageUtils.normalize('ar'), 'ar');
      expect(LanguageUtils.normalize('AR'), 'ar');
      expect(LanguageUtils.normalize('arabic'), 'ar');
      expect(LanguageUtils.normalize('arabe'), 'ar');
    });

    test('normalizes Hausa codes', () {
      expect(LanguageUtils.normalize('ha'), 'ha');
      expect(LanguageUtils.normalize('HA'), 'ha');
      expect(LanguageUtils.normalize('hausa'), 'ha');
      expect(LanguageUtils.normalize('Hausa'), 'ha');
    });

    test('normalizes Djerma/Zarma codes', () {
      expect(LanguageUtils.normalize('dje'), 'dje');
      expect(LanguageUtils.normalize('za'), 'dje');
      expect(LanguageUtils.normalize('zr'), 'dje');
      expect(LanguageUtils.normalize('zarma'), 'dje');
      expect(LanguageUtils.normalize('djerma'), 'dje');
    });

    test('returns lowercase for unknown codes', () {
      expect(LanguageUtils.normalize('es'), 'es');
      expect(LanguageUtils.normalize('DE'), 'de');
    });
  });

  group('LanguageUtils.fallbackOrder', () {
    test('starts with the preferred language', () {
      final order = LanguageUtils.fallbackOrder('fr');
      expect(order.first, 'fr');
    });

    test('always includes default language', () {
      final order = LanguageUtils.fallbackOrder('fr');
      expect(order.contains('en'), isTrue);
    });

    test('returns unique values', () {
      final order = LanguageUtils.fallbackOrder('en');
      final uniqueOrder = order.toSet().toList();
      expect(order.length, uniqueOrder.length);
    });

    test('handles null preferred language', () {
      final order = LanguageUtils.fallbackOrder(null);
      expect(order.first, 'en'); // default
      expect(order.length, greaterThan(1));
    });

    test('includes Hausa and Djerma in fallback', () {
      final order = LanguageUtils.fallbackOrder('fr');
      expect(order.contains('ha'), isTrue);
      expect(order.contains('dje'), isTrue);
    });

    test('preferred language is first, default is second', () {
      final order = LanguageUtils.fallbackOrder('ha');
      expect(order[0], 'ha');
      expect(order[1], 'en');
    });

    test('does not contain empty strings', () {
      final order = LanguageUtils.fallbackOrder('');
      expect(order.where((s) => s.isEmpty), isEmpty);
    });
  });

  group('LanguageUtils.defaultLanguage', () {
    test('is English', () {
      expect(LanguageUtils.defaultLanguage, 'en');
    });
  });
}
