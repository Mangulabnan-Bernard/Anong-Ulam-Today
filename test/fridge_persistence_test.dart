// Verifies the fridge is persisted to Hive and survives an app "restart"
// (box closed + reopened with a fresh provider container).
import 'dart:io';

import 'package:anong_ulam_today/data/local/ingredient_adapter.dart';
import 'package:anong_ulam_today/data/local/local_storage.dart';
import 'package:anong_ulam_today/data/models/ingredient.dart';
import 'package:anong_ulam_today/presentation/providers/fridge_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDir;

  const bawang = Ingredient(
    id: 'bawang',
    name: 'Bawang',
    nameEn: 'Garlic',
    category: IngredientCategory.pampalasa,
    emoji: '🧄',
  );

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('fridge_hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(IngredientAdapter().typeId)) {
      Hive.registerAdapter(IngredientAdapter());
    }
    await Hive.openBox<Ingredient>(fridgeBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('added ingredients persist across a simulated restart', () async {
    // Session 1: add an ingredient.
    final container1 = ProviderContainer();
    container1.read(fridgeProvider.notifier).add(bawang);
    expect(container1.read(fridgeProvider), [bawang]);
    container1.dispose();

    // Simulate restart: close the box, reopen it, fresh container.
    await Hive.box<Ingredient>(fridgeBoxName).close();
    await Hive.openBox<Ingredient>(fridgeBoxName);

    final container2 = ProviderContainer();
    final restored = container2.read(fridgeProvider);
    expect(restored.length, 1);
    expect(restored.single.id, 'bawang');
    expect(restored.single.category, IngredientCategory.pampalasa);
    expect(restored.single.emoji, '🧄');
    container2.dispose();
  });

  test('removing an ingredient is persisted', () async {
    final container = ProviderContainer();
    final notifier = container.read(fridgeProvider.notifier);
    notifier.add(bawang);
    notifier.remove(bawang);
    expect(container.read(fridgeProvider), isEmpty);
    expect(fridgeBox.isEmpty, isTrue);
    container.dispose();
  });

  test('add is idempotent on duplicate ids', () async {
    final container = ProviderContainer();
    final notifier = container.read(fridgeProvider.notifier);
    notifier.add(bawang);
    notifier.add(bawang);
    expect(container.read(fridgeProvider).length, 1);
    container.dispose();
  });

  test('addByName stores a free-text custom ingredient', () async {
    final container = ProviderContainer();
    final added =
        container.read(fridgeProvider.notifier).addByName('dragon fruit');
    expect(added, isNotNull);
    expect(added!.id, 'custom_dragon_fruit');
    expect(fridgeBox.get('custom_dragon_fruit')?.name, 'dragon fruit');
    container.dispose();
  });
}
