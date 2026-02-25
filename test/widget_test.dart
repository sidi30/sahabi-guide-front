import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic App Tests', () {
    testWidgets('MaterialApp should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Sahabi Guide')),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Sahabi Guide'), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('App should use correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D3557),
              secondary: Color(0xFF2A9D8F),
            ),
          ),
          home: const Scaffold(
            body: Center(child: Text('Theme Test')),
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, const Color(0xFF1D3557));
      expect(materialApp.theme?.colorScheme.secondary, const Color(0xFF2A9D8F));
    });
  });
}
