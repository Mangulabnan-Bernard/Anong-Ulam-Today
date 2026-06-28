// Verifies ADD ULAM user-created recipes persist to Hive (JSON round-trip of
// enums + nested ingredients) and merge into the global recipe catalog.
import 'dart:io';

import 'package:anong_ulam_today/data/local/local_storage.dart';
import 'package:anong_ulam_today/data/models/recipe.dart';
import 'package:anong_ulam_today/presentation/providers/recipe_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory tempDir;

  const seed = Recipe(
    id: 'adobo',
    title: 'Adobo',
    description: '',
    mealTypes: [MealType.lunch],
    difficulty: Difficulty.easy,
    cookingTimeMins: 45,
    ingredients: [RecipeIngredient(name: 'Manok', quantity: '1 kg')],
    instructions: ['Lutuin'],
  );

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('user_recipes_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(userRecipesBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  test('user recipe persists with nested fields across a restart', () async {
    final container1 = ProviderContainer();
    const recipe = Recipe(
      id: 'user_1',
      title: 'Arroz Caldo',
      description: 'Lugaw na may manok',
      mealTypes: [MealType.breakfast, MealType.any],
      difficulty: Difficulty.medium,
      cookingTimeMins: 40,
      ingredients: [
        RecipeIngredient(name: 'Bigas', quantity: '1 tasa'),
        RecipeIngredient(name: 'Luya', quantity: '', isOptional: true),
      ],
      instructions: ['Step 1', 'Step 2'],
      emoji: '🥣',
      rating: 4.2,
      region: 'Sariling luto',
    );
    container1.read(userRecipesProvider.notifier).addRecipe(recipe);
    container1.dispose();

    // Simulate restart.
    await userRecipesBox.close();
    await Hive.openBox<String>(userRecipesBoxName);

    final container2 = ProviderContainer();
    final restored = container2.read(userRecipesProvider);
    expect(restored.length, 1);
    final got = restored.single;
    expect(got.id, 'user_1');
    expect(got.title, 'Arroz Caldo');
    expect(got.mealTypes, [MealType.breakfast, MealType.any]);
    expect(got.difficulty, Difficulty.medium);
    expect(got.ingredients.length, 2);
    expect(got.ingredients[1].isOptional, isTrue);
    expect(got.instructions, ['Step 1', 'Step 2']);
    expect(got.emoji, '🥣');
    container2.dispose();
  });

  test('recipesProvider merges seed catalog + user recipes', () {
    final container = ProviderContainer(
      overrides: [seedRecipesProvider.overrideWithValue([seed])],
    );
    const userRecipe = Recipe(
      id: 'user_2',
      title: 'Sinangag',
      description: '',
      mealTypes: [MealType.any],
      difficulty: Difficulty.easy,
      cookingTimeMins: 15,
      ingredients: [RecipeIngredient(name: 'Kanin', quantity: '2 tasa')],
      instructions: ['Igisa'],
    );
    container.read(userRecipesProvider.notifier).addRecipe(userRecipe);

    final all = container.read(recipesProvider).map((r) => r.id);
    expect(all, containsAll(['adobo', 'user_2']));
    container.dispose();
  });

  test('removeRecipe deletes a user recipe (persisted)', () {
    final container = ProviderContainer();
    final notifier = container.read(userRecipesProvider.notifier);
    notifier.addRecipe(seed.copyForTest('user_3'));
    notifier.removeRecipe('user_3');
    expect(container.read(userRecipesProvider), isEmpty);
    expect(userRecipesBox.isEmpty, isTrue);
    container.dispose();
  });
}

extension on Recipe {
  Recipe copyForTest(String newId) => Recipe(
        id: newId,
        title: title,
        description: description,
        mealTypes: mealTypes,
        difficulty: difficulty,
        cookingTimeMins: cookingTimeMins,
        ingredients: ingredients,
        instructions: instructions,
      );
}
