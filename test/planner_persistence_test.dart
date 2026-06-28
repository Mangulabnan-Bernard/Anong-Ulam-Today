// Verifies the weekly meal plan persists to Hive and survives a simulated
// app restart (box closed + reopened with a fresh provider container).
import 'dart:io';

import 'package:anong_ulam_today/data/local/local_storage.dart';
import 'package:anong_ulam_today/presentation/providers/planner_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('planner_hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(plannerBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('assigned meals persist across a simulated restart', () async {
    final container1 = ProviderContainer();
    container1.read(plannerProvider.notifier).setMeal('mon', 'adobo');
    container1.read(plannerProvider.notifier).setMeal('tue', 'tinola');
    expect(container1.read(plannerProvider), {'mon': 'adobo', 'tue': 'tinola'});
    container1.dispose();

    await plannerBox.close();
    await Hive.openBox<String>(plannerBoxName);

    final container2 = ProviderContainer();
    expect(container2.read(plannerProvider), {'mon': 'adobo', 'tue': 'tinola'});
    container2.dispose();
  });

  test('setMeal overwrites the existing meal for that day', () async {
    final container = ProviderContainer();
    final notifier = container.read(plannerProvider.notifier);
    notifier.setMeal('wed', 'adobo');
    notifier.setMeal('wed', 'sinigang');
    expect(container.read(plannerProvider)['wed'], 'sinigang');
    container.dispose();
  });

  test('removeMeal clears the day and is persisted', () async {
    final container = ProviderContainer();
    final notifier = container.read(plannerProvider.notifier);
    notifier.setMeal('fri', 'adobo');
    notifier.removeMeal('fri');
    expect(container.read(plannerProvider), isEmpty);
    expect(plannerBox.isEmpty, isTrue);
    container.dispose();
  });
}
