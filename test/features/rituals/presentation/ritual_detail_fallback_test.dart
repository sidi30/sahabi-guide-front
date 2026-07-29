// Le repli sur la guidance statique (`ritual_guidance.dart`) doit être VISIBLE,
// et sa prose masculine ne doit JAMAIS être servie à une pèlerine.
//
// Rappel du mécanisme : `RitualDetailSection` bascule sur `ritual_guidance.dart`
// dès que `ritual.steps` est vide (rite non migré, JSON illisible côté serveur,
// hors-ligne sans cache, erreur API). Cette guidance est une prose française
// mixte qui contient des actes explicitement masculins.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:sahabi_guide/core/di/injection_container.dart';
import 'package:sahabi_guide/core/services/tts_service.dart';
import 'package:sahabi_guide/features/rituals/presentation/widgets/ritual_detail_section.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import 'package:sahabi_guide/l10n/fallback_material_localizations.dart';
import 'package:sahabi_guide/shared/models/ritual_model.dart';

/// Extraits de `ritual_guidance.dart` réservés aux hommes : aucun d'eux ne doit
/// atteindre l'écran d'une pèlerine.
const _maleOnlyFragments = [
  "Pour l'homme",
  'les hommes accélèrent',
  "Idtiba'",
  'Raml',
  'Halq',
];

/// Rite AYANT une guidance statique (`kRitualGuidance['tawaf']`), sans étapes
/// serveur : c'est exactement le cas qui déclenchait le repli silencieux.
const _tawafSansEtapes = RitualModel(
  id: 'tawaf',
  name: 'Tawaf',
  order: 2,
  description: '',
);

const _tawafAvecEtapes = RitualModel(
  id: 'tawaf',
  name: 'Tawaf',
  order: 2,
  description: 'Sept tours autour de la Kaaba.',
  steps: ['Étape serveur 1', 'Étape serveur 2'],
);

Widget _host(RitualModel ritual, String gender, {Locale locale = const Locale('fr')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...haFallbackLocalizationsDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: RitualDetailSection(
          ritual: ritual,
          audioLanguage: 'fr',
          gender: gender,
        ),
      ),
    ),
  );
}

/// Tout le texte réellement peint à l'écran.
List<String> _renderedText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
    .toList();

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));

  setUp(() {
    // `RitualDetailSection` résout TtsService via le service locator.
    if (!sl.isRegistered<TtsService>()) {
      sl.registerLazySingleton<TtsService>(() => TtsService());
    }
  });

  tearDown(() => GetIt.instance.reset());

  testWidgets('steps vides + profil FEMININ : bandeau de mode dégradé, aucune prose masculine',
      (tester) async {
    await tester.pumpWidget(_host(_tawafSansEtapes, 'FEMALE'));
    await tester.pump();

    // 1. Le repli est SIGNALÉ.
    expect(find.text(fr.rituals_fallback_notice_title), findsOneWidget);
    expect(find.text(fr.rituals_fallback_female_body), findsOneWidget);

    // 2. Rien de la guidance masculine n'est peint.
    final texts = _renderedText(tester);
    for (final fragment in _maleOnlyFragments) {
      expect(
        texts.any((t) => t.contains(fragment)),
        isFalse,
        reason: 'Fragment masculin "$fragment" affiché à une pèlerine',
      );
    }
    // Le bouton « lire étape par étape » n'ouvre pas un lecteur vide.
    expect(find.text(fr.ritual_detail_read_steps), findsNothing);
  });

  testWidgets('steps vides + profil MASCULIN : la guidance statique reste affichée, mais signalée',
      (tester) async {
    await tester.pumpWidget(_host(_tawafSansEtapes, 'MALE'));
    await tester.pump();

    // Le bandeau est là pour tout le monde : le contenu n'est pas personnalisé.
    expect(find.text(fr.rituals_fallback_notice_title), findsOneWidget);
    expect(find.text(fr.rituals_fallback_notice_body), findsOneWidget);
    expect(find.text(fr.rituals_fallback_female_body), findsNothing);

    // Contrôle négatif : la prose masculine EST bien rendue ici, donc le test
    // féminin ci-dessus prouve réellement quelque chose.
    final texts = _renderedText(tester);
    expect(texts.any((t) => t.contains("Pour l'homme")), isTrue);
  });

  testWidgets('étapes fournies par le serveur : aucun bandeau de mode dégradé',
      (tester) async {
    await tester.pumpWidget(_host(_tawafAvecEtapes, 'FEMALE'));
    await tester.pump();

    expect(find.text(fr.rituals_fallback_notice_title), findsNothing);
    expect(find.text('Étape serveur 1'), findsOneWidget);
  });

  testWidgets('le bandeau de mode dégradé est traduit (haoussa)', (tester) async {
    final ha = lookupAppLocalizations(const Locale('ha'));
    await tester.pumpWidget(
      _host(_tawafSansEtapes, 'FEMALE', locale: const Locale('ha')),
    );
    await tester.pump();

    expect(find.text(ha.rituals_fallback_notice_title), findsOneWidget);
    expect(ha.rituals_fallback_notice_title,
        isNot(equals(fr.rituals_fallback_notice_title)));
  });
}
