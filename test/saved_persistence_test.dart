// Verifies saved/favorited recipes persist to Hive and survive an app
// "restart" (box closed + reopened with a fresh provider container).
import 'dart:io';

import 'package:anong_ulam_today/data/local/local_storage.dart';
import 'package:anong_ulam_today/presentation/providers/recipe_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('saved_hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(savedBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('saved recipes persist across a simulated restart', () async {
    // Session 1: save two recipes.
    final container1 = ProviderContainer();
    container1.read(savedRecipesProvider.notifier).toggle('adobo');
    container1.read(savedRecipesProvider.notifier).toggle('tinola');
    expect(container1.read(savedRecipesProvider), {'adobo', 'tinola'});
    container1.dispose();

    // Simulate restart: close the box, reopen it, fresh container.
    await savedBox.close();
    await Hive.openBox<String>(savedBoxName);

    final container2 = ProviderContainer();
    final restored = container2.read(savedRecipesProvider);
    expect(restored, {'adobo', 'tinola'});
    container2.dispose();
  });

  test('toggling an already-saved recipe unsaves it (persisted)', () async {
    final container = ProviderContainer();
    final notifier = container.read(savedRecipesProvider.notifier);
    notifier.toggle('adobo');
    notifier.toggle('adobo'); // toggle off
    expect(container.read(savedRecipesProvider), isEmpty);
    expect(savedBox.isEmpty, isTrue);
    container.dispose();
  });

  test('isSaved reflects current saved state', () async {
    final container = ProviderContainer();
    final notifier = container.read(savedRecipesProvider.notifier);
    expect(notifier.isSaved('adobo'), isFalse);
    notifier.toggle('adobo');
    expect(notifier.isSaved('adobo'), isTrue);
    container.dispose();
  });
}
