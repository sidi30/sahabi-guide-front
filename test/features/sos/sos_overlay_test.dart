// Le bouton SOS est déplaçable et rangeable pour ne pas gêner la navigation.
// Ce qui est vérifié ici, c'est que « ne plus gêner » n'a jamais coûté un geste
// supplémentaire en situation d'urgence : rangé ou non, UN appui alerte.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahabi_guide/features/sos/presentation/providers/sos_provider.dart';
import 'package:sahabi_guide/features/sos/presentation/widgets/sos_button.dart';
import 'package:sahabi_guide/features/sos/presentation/widgets/sos_overlay.dart';
import 'package:sahabi_guide/l10n/app_localizations.dart';
import 'package:sahabi_guide/l10n/fallback_material_localizations.dart';

import 'sos_fakes.dart';

Widget overlayHarness(SosQueueNotifier notifier) {
  return ProviderScope(
    overrides: [sosQueueProvider.overrideWith((ref) => notifier)],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...haFallbackLocalizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Reproduit la vraie coquille : la couche SOS vit dans le `body`, avec
      // une AppBar au-dessus et une barre de navigation en dessous. Le body est
      // donc NETTEMENT plus court que l'écran — c'est précisément ce qui avait
      // fait disparaître le bouton quand sa position était calculée sur la
      // hauteur de l'écran.
      home: Scaffold(
        appBar: AppBar(title: const Text('x')),
        bottomNavigationBar: const SizedBox(height: 80),
        body: const Stack(children: [SosOverlay()]),
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'le bouton est ENTIÈREMENT visible dans le body, pas sous la barre de nav',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    final button = find.byType(SosFloatingButton);
    expect(button, findsOneWidget);

    // La zone réellement peinte du body : c'est elle qui doit contenir le
    // bouton, pas l'écran entier.
    final bodyRect = tester.getRect(find.byType(SosOverlay));
    final buttonRect = tester.getRect(button);

    expect(buttonRect.bottom, lessThanOrEqualTo(bodyRect.bottom),
        reason: 'le bouton dépasse sous le body : invisible pour le pèlerin');
    expect(buttonRect.top, greaterThanOrEqualTo(bodyRect.top));
    expect(buttonRect.left, greaterThanOrEqualTo(bodyRect.left));
    expect(buttonRect.right, lessThanOrEqualTo(bodyRect.right));

    // Et il reste touchable : un appui ouvre bien le compte à rebours.
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('ANNULER'), findsOneWidget);
  });

  testWidgets('un glissement ne peut pas sortir le bouton de la zone',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    // Poussée volontairement excessive vers le bas à droite.
    await tester.drag(find.byType(SosFloatingButton), const Offset(2000, 2000));
    await tester.pumpAndSettle();

    final bodyRect = tester.getRect(find.byType(SosOverlay));
    final buttonRect = tester.getRect(find.byType(SosFloatingButton));

    expect(buttonRect.bottom, lessThanOrEqualTo(bodyRect.bottom));
    expect(buttonRect.right, lessThanOrEqualTo(bodyRect.right));
  });

  testWidgets('déployé par défaut, un appui ouvre le compte à rebours',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    expect(find.byType(SosFloatingButton), findsOneWidget);

    await tester.tap(find.byType(SosFloatingButton));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ANNULER'), findsOneWidget);
    expect(notifier.state.requests, isEmpty, reason: 'rien envoyé au seul tap');
  });

  testWidgets('le badge × range le bouton, et la position est mémorisée',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Rangé : plus de bouton complet, mais une poignée toujours visible.
    expect(find.byType(SosFloatingButton), findsNothing);
    expect(find.byIcon(Icons.sos_rounded), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sos_btn_collapsed'), isTrue);
  });

  testWidgets('RANGÉ, un seul appui déclenche quand même le SOS',
      (tester) async {
    SharedPreferences.setMockInitialValues({'sos_btn_collapsed': true});
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    expect(find.byType(SosFloatingButton), findsNothing,
        reason: 'on démarre bien à l\'état rangé');

    await tester.tap(find.byIcon(Icons.sos_rounded));
    await tester.pump(const Duration(milliseconds: 200));

    // Le compte à rebours s'ouvre directement : pas de « ressortir d'abord ».
    expect(find.text('ANNULER'), findsOneWidget);
  });

  testWidgets('un appui long sur la poignée ressort le bouton sans alerter',
      (tester) async {
    SharedPreferences.setMockInitialValues({'sos_btn_collapsed': true});
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    await tester.longPress(find.byIcon(Icons.sos_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SosFloatingButton), findsOneWidget);
    expect(find.text('ANNULER'), findsNothing, reason: 'aucune alerte déclenchée');
    expect(notifier.state.requests, isEmpty);
  });

  testWidgets('glisser le bouton le déplace sans déclencher de SOS',
      (tester) async {
    final notifier =
        buildNotifier(store: FakeSosQueueStore(), api: FakeSosApi());

    await tester.pumpWidget(overlayHarness(notifier));
    await tester.pumpAndSettle();

    final before = tester.getTopLeft(find.byType(SosFloatingButton));
    await tester.drag(find.byType(SosFloatingButton), const Offset(60, -120));
    await tester.pumpAndSettle();

    final after = tester.getTopLeft(find.byType(SosFloatingButton));
    expect(after, isNot(before), reason: 'le bouton a bougé');
    expect(find.text('ANNULER'), findsNothing,
        reason: 'un glissement ne doit jamais alerter');
    expect(notifier.state.requests, isEmpty);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('sos_btn_left'), isNotNull,
        reason: 'la position est mémorisée');
  });
}
