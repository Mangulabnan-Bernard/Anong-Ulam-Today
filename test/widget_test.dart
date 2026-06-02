// Basic smoke test for Anong Ulam Today.
import 'package:anong_ulam_today/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anong_ulam_today/presentation/screens/home_screen.dart';

void main() {
  testWidgets('Home screen shows the meal grid (Tagalog default)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('tl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    // The "Kahit Ano!" random tile should be present (Tagalog).
    expect(find.text('Kahit Ano!'), findsOneWidget);
    expect(find.text('Almusal'), findsOneWidget);
    expect(find.text('Tanghalian'), findsOneWidget);
    expect(find.text('Hapunan'), findsOneWidget);
  });

  testWidgets('Home screen switches to English labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Anything!'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
  });
}
