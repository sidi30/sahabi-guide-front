class LanguageUtils {
  static const String defaultLanguage = 'en';

  static String normalize(String? code) {
    if (code == null || code.isEmpty) {
      return defaultLanguage;
    }
    final lower = code.toLowerCase();
    if (lower.startsWith('en') || lower.contains('english')) return 'en';
    if (lower.startsWith('fr') || lower.contains('franc')) return 'fr';
    if (lower.startsWith('ar') || lower.contains('arab')) return 'ar';
    if (lower.startsWith('ha') || lower.contains('hausa')) return 'ha';
    if (lower == 'za' ||
        lower == 'zr' ||
        lower == 'dje' ||
        lower.contains('zarma') ||
        lower.contains('djerma')) {
      return 'dje';
    }
    return lower;
  }

  static List<String> fallbackOrder(String? preferred) {
    final normalized = normalize(preferred);
    final ordered = <String>{
      normalized,
      defaultLanguage,
      'ha',
      'dje',
      'fr',
      'ar',
    };
    ordered.removeWhere((code) => code.isEmpty);
    return ordered.toList();
  }
}

