import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sahabi_guide/features/bot/data/models/bot_message_model.dart';
import 'package:sahabi_guide/features/bot/data/services/bot_service.dart';
import 'package:sahabi_guide/features/bot/data/services/translate_api.dart';
import 'package:sahabi_guide/features/bot/presentation/providers/bot_provider.dart';
import 'package:sahabi_guide/features/bot/presentation/widgets/ai_consent_dialog.dart';

/// Contenu FR du message d'étape du tour guidé (question + 💡 description),
/// tel que `BotService._generateQuestionMessage` le produit désormais avec
/// `originalLang = 'fr'` pour ha/en (voir bot_service.dart).
const _kFrenchStep = 'Avez-vous effectué votre Ihram ?\n\n💡 Portez les deux '
    'pièces de tissu blanc et formulez votre intention.';

/// Faux [BotService] : produit exactement le contrat du vrai service APRÈS le
/// correctif — un message de bienvenue localisé (natif dans la locale) suivi
/// d'un message d'étape guidé en FR (`originalLang: 'fr'`) avec des réponses
/// rapides dynamiques FR. On isole ainsi la logique de traduction du provider
/// sans dépendre du GPS / des assets / de l10n du vrai BotService.
class _FakeBotService implements BotService {
  final List<BotMessageModel> _history = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<BotMessageModel> startConversation({String locale = 'fr'}) async {
    _history
      ..clear()
      // Bienvenue : réellement localisée -> langue d'origine = la locale (natif).
      ..add(BotMessageModel.bot(
        id: 'welcome',
        content: locale == 'ha' ? 'Barka da zuwa' : 'Bienvenue',
        originalLang: locale,
      ))
      // Étape guidée : contenu scripté FR + réponses rapides dynamiques FR.
      ..add(BotMessageModel.bot(
        id: 'step1',
        content: _kFrenchStep,
        quickReplies: const ['Oui', 'Non'],
        relatedStepId: 'ihram',
        originalLang: 'fr',
      ));
    return _history.last;
  }

  @override
  Future<BotMessageModel> handleAnswer(String answer,
      {String locale = 'fr'}) async {
    _history.add(BotMessageModel.user(
      id: 'user-${_history.length}',
      content: answer,
      originalLang: locale,
    ));
    final next = BotMessageModel.bot(
      id: 'step2',
      content: 'Êtes-vous arrivé à la Kaaba ?\n\n💡 Effectuez le Tawaf.',
      quickReplies: const ['Oui', 'Non'],
      relatedStepId: 'tawaf',
      originalLang: 'fr',
    );
    _history.add(next);
    return next;
  }

  @override
  List<BotMessageModel> getMessageHistory() => List.unmodifiable(_history);

  @override
  int getProgressPercentage() => 10;

  @override
  Map<String, dynamic> getStats() => const {};

  @override
  void dispose() {}

  // Tout le reste de l'API BotService est inutilisé par ces tests.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Faux [TranslateApi] : mappe chaque texte vers un marqueur détectable
/// `"<TARGET>::<texte>"` et compte les appels, pour prouver quel texte a été
/// (ou n'a pas été) envoyé à l'IA.
class _RecordingTranslateApi implements TranslateApi {
  int callCount = 0;
  final List<String> lastTexts = [];

  @override
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLang,
    String? sourceLang,
  }) async {
    callCount++;
    lastTexts
      ..clear()
      ..addAll(texts);
    return texts.map((t) => '${targetLang.toUpperCase()}::$t').toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeBotService bot;
  late _RecordingTranslateApi translate;
  late BotChatNotifier notifier;

  setUp(() {
    // Store SharedPreferences vierge ; le consentement est ensuite écrit
    // explicitement par test via AiConsentDialog.setConsent (write-through sur
    // l'instance cachée, robuste au cache statique de getInstance).
    SharedPreferences.setMockInitialValues({});
    bot = _FakeBotService();
    translate = _RecordingTranslateApi();
    notifier = BotChatNotifier(
      botService: bot,
      translateApi: translate,
      logger: Logger(level: Level.off),
    );
    addTearDown(notifier.dispose);
  });

  BotMessageModel step(BotChatNotifier n, String id) =>
      n.state.messages.firstWhere((m) => m.id == id);

  test('(a) ouverture directe en Hausa : étape + réponses rapides traduites, '
      'bienvenue native intacte', () async {
    await AiConsentDialog.setConsent(true);

    await notifier.startConversation(locale: 'ha');

    final s = step(notifier, 'step1');
    // Contenu de l'étape = marqueur traduit, PAS le FR brut.
    expect(s.content, 'HA::$_kFrenchStep');
    // Réponses rapides dynamiques : libellés traduits (affichage), valeur
    // canonique FR conservée comme clé.
    expect(s.quickReplyLabels, {'Oui': 'HA::Oui', 'Non': 'HA::Non'});
    // Bienvenue déjà en Hausa (originalLang == 'ha') : non renvoyée à l'IA.
    expect(step(notifier, 'welcome').content, 'Barka da zuwa');
    // Un seul appel batch ; il contient le contenu ET les réponses rapides.
    expect(translate.callCount, 1);
    expect(translate.lastTexts, containsAll(<String>[_kFrenchStep, 'Oui', 'Non']));
    expect(translate.lastTexts, isNot(contains('Barka da zuwa')));
  });

  test('(b) bascule fr -> ha puis ha -> fr : traduit puis restaure le FR '
      "d'origine", () async {
    await AiConsentDialog.setConsent(true);

    // Ouverture en français : l'étape reste FR, aucun appel IA.
    await notifier.startConversation(locale: 'fr');
    expect(step(notifier, 'step1').content, _kFrenchStep);
    expect(step(notifier, 'step1').quickReplyLabels, isNull);
    expect(translate.callCount, 0);

    // Bascule vers le Hausa : l'étape existante est traduite.
    await notifier.translateHistoryTo('ha');
    expect(step(notifier, 'step1').content, 'HA::$_kFrenchStep');
    expect(step(notifier, 'step1').quickReplyLabels,
        {'Oui': 'HA::Oui', 'Non': 'HA::Non'});
    expect(translate.callCount, 1);

    // Re-bascule vers le français : on restaure le texte FR d'origine, sans
    // nouvel appel IA (fr == langue d'origine de l'étape).
    await notifier.translateHistoryTo('fr');
    expect(step(notifier, 'step1').content, _kFrenchStep);
    expect(step(notifier, 'step1').quickReplyLabels, isNull);
    expect(translate.callCount, 1);
  });

  test('(c) consentement absent : aucune traduction, on reste en FR (pas de '
      'crash)', () async {
    // Pas de setConsent -> consentement absent.
    final outcome = await notifier.startConversation(locale: 'ha');

    expect(outcome, TranslateHistoryOutcome.consentRequired);
    // Rien envoyé à l'IA.
    expect(translate.callCount, 0);
    // L'étape reste en français, réponses rapides brutes.
    expect(step(notifier, 'step1').content, _kFrenchStep);
    expect(step(notifier, 'step1').quickReplyLabels, isNull);
  });

  test('(d) cache : un nouveau tour ne re-traduit pas les anciens messages',
      () async {
    await AiConsentDialog.setConsent(true);

    await notifier.startConversation(locale: 'ha');
    expect(translate.callCount, 1); // étape 1 + Oui/Non

    // Nouvelle étape (step2) : seuls ses textes neufs partent à l'IA ; step1 /
    // Oui / Non sont servis depuis le cache (pas de re-traduction).
    await notifier.sendAnswer('Oui', locale: 'ha');
    expect(step(notifier, 'step2').content,
        'HA::Êtes-vous arrivé à la Kaaba ?\n\n💡 Effectuez le Tawaf.');
    expect(translate.callCount, 2);
    // Le 2e appel ne contient QUE le contenu neuf (Oui/Non déjà en cache).
    expect(translate.lastTexts,
        contains('Êtes-vous arrivé à la Kaaba ?\n\n💡 Effectuez le Tawaf.'));
    expect(translate.lastTexts, isNot(contains('Oui')));
    // step1 reste correctement traduit.
    expect(step(notifier, 'step1').content, 'HA::$_kFrenchStep');
  });
}
