import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sahabi_guide/main.dart';

void main() {
  group('Hajj Companion App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => OnboardingScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify that the app builds successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Onboarding screen should be displayed initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Should show onboarding screen title
      expect(find.text('Hajj Companion'), findsOneWidget);
      
      // Should show role selection
      expect(find.text('I am a...'), findsOneWidget);
      expect(find.text('Pilgrim'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('App should use correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF1D3557),
                secondary: const Color(0xFF2A9D8F),
              ),
            ),
            home: OnboardingScreen(),
          ),
        ),
      );

      // Check primary color is used in the UI
      final container = tester.widget<Container>(
        find.byType(Container).at(1), // The logo container
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2A9D8F)); // Secondary color
    });
  });
}
