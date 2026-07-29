// Le geste et ce qu'il déclenche réellement : un compte à rebours annulé
// n'envoie RIEN, et le bandeau n'annonce « reçu » qu'après le serveur.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahabi_guide/features/sos/domain/sos_request.dart';
import 'package:sahabi_guide/features/sos/presentation/providers/sos_provider.dart';
import 'package:sahabi_guide/features/sos/presentation/widgets/sos_button.dart';
import 'package:sahabi_guide/features/sos/presentation/widgets/sos_status_banner.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import 'package:sahabi_guide/l10n/fallback_material_localizations.dart';

import 'sos_fakes.dart';

Widget harness(SosQueueNotifier notifier, {Locale locale = const Locale('fr')}) {
  return ProviderScope(
    overrides: [sosQueueProvider.overrideWith((ref) => notifier)],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...haFallbackLocalizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Column(
          children: [SosStatusBanner(), Spacer(), SosFloatingButton()],
        ),
      ),
    ),
  );
}

/// Ouvre le compte à rebours en touchant le bouton SOS.
Future<void> openCountdown(WidgetTester tester) async {
  await tester.tap(find.byType(SosFloatingButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('un appui sur SOS ouvre un compte à rebours, sans rien envoyer',
      (tester) async {
    final store = FakeSosQueueStore();
    final api = FakeSosApi();
    final notifier = buildNotifier(store: store, api: api);

    await tester.pumpWidget(harness(notifier));
    await openCountdown(tester);

    expect(find.text('ANNULER'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    // Rien n'est parti et rien n'est en file tant que le décompte court.
    expect(api.sent, isEmpty);
    expect(store.entries, isEmpty);

    await tester.tap(find.text('ANNULER'));
    await tester.pumpAndSettle();
  });

  testWidgets('un compte à rebours ANNULÉ n\'envoie RIEN', (tester) async {
    final store = FakeSosQueueStore();
    final api = FakeSosApi();
    final notifier = buildNotifier(store: store, api: api);

    await tester.pumpWidget(harness(notifier));
    await openCountdown(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.text('ANNULER'));
    await tester.pumpAndSettle();

    // Bien après la fin théorique du décompte : toujours rien.
    await tester.pump(const Duration(seconds: 10));

    expect(api.sent, isEmpty);
    expect(store.entries, isEmpty);
    expect(notifier.state.current, isNull);
    expect(find.byType(SosStatusBanner), findsOneWidget);
    expect(find.text('Envoi en cours…'), findsNothing);
  });

  testWidgets('le décompte mené à son terme envoie le SOS et le confirme',
      (tester) async {
    final store = FakeSosQueueStore();
    final api = FakeSosApi();
    final notifier = buildNotifier(store: store, api: api);

    await tester.pumpWidget(harness(notifier));
    await openCountdown(tester);

    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(api.sent, hasLength(1));
    expect(store.entries.single.status, SosDeliveryStatus.sent);
    expect(find.text('SOS reçu par votre agence'), findsOneWidget);
  });

  testWidgets('le bandeau n\'annonce le succès qu\'après la réponse serveur',
      (tester) async {
    final store = FakeSosQueueStore();
    final api = ManualSosApi();
    final notifier = buildNotifier(store: store, api: api);

    await tester.pumpWidget(harness(notifier));
    await openCountdown(tester);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump();
    await tester.pump();

    expect(find.text('Envoi en cours…'), findsOneWidget);
    expect(find.text('SOS reçu par votre agence'), findsNothing);

    api.respond();
    await tester.pumpAndSettle();

    expect(find.text('SOS reçu par votre agence'), findsOneWidget);
  });

  testWidgets('un SOS en attente reste affiché avec son nombre de tentatives',
      (tester) async {
    final store = FakeSosQueueStore();
    final api = FakeSosApi(alwaysFail: true);
    final notifier =
        buildNotifier(store: store, api: api, maxAutomaticAttempts: 2);

    await tester.pumpWidget(harness(notifier));
    await notifier.trigger();
    await notifier.flush();
    await tester.pump();

    // Après épuisement des tentatives : échec explicite + réessai proposé.
    expect(find.text('Échec de l\'envoi — réessayer'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    // Le bandeau ne disparaît pas tout seul.
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Échec de l\'envoi — réessayer'), findsOneWidget);
  });

  testWidgets('sans session valide, le bandeau dit quoi faire', (tester) async {
    // Cas très concret : la coquille principale est accessible sans être
    // connecté ; le serveur répond 401. Afficher l'erreur technique
    // n'aiderait pas le pèlerin.
    final store = FakeSosQueueStore();
    final api = FakeSosApi(
      alwaysFail: true,
      retryable: false,
      authRequired: true,
    );
    final notifier = buildNotifier(store: store, api: api);

    await tester.pumpWidget(harness(notifier));
    await notifier.trigger();
    await notifier.flush();
    await tester.pump();

    expect(find.text('Envoi impossible — reconnectez-vous'), findsOneWidget);
    expect(find.text('Échec de l\'envoi — réessayer'), findsNothing);
  });

  testWidgets('le bandeau dit quand le SOS part sans position', (tester) async {
    final store = FakeSosQueueStore();
    final api = FakeSosApi();
    final notifier = buildNotifier(store: store, api: api, fix: null);

    await tester.pumpWidget(harness(notifier));
    await notifier.trigger();
    await notifier.flush();
    await tester.pump();

    expect(find.text('Envoyé sans position'), findsOneWidget);
  });

  testWidgets('le bouton SOS est accessible et respecte la cible tactile',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(harness(notifier));

    final size = tester.getSize(find.byType(SosFloatingButton));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));

    expect(
      tester.getSemantics(find.byType(SosFloatingButton)).label,
      contains('urgence'),
    );

    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('le bouton et le décompte sont localisés (haoussa)',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(harness(notifier, locale: const Locale('ha')));
    expect(find.text('GAGGAWA'), findsOneWidget);

    await openCountdown(tester);
    expect(find.text('SOKE'), findsOneWidget);
    expect(find.text('Za a aika SOS cikin'), findsOneWidget);

    await tester.tap(find.text('SOKE'));
    await tester.pumpAndSettle();
  });
}
