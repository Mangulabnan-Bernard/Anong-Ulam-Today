// Unit tests for the fridge → recipe matching logic.
import 'package:anong_ulam_today/data/models/recipe.dart';
import 'package:anong_ulam_today/presentation/providers/recipe_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const recipe = Recipe(
    id: 'r1',
    title: 'Test Adobo',
    description: 'd',
    mealTypes: [MealType.lunch],
    difficulty: Difficulty.easy,
    cookingTimeMins: 30,
    ingredients: [
      RecipeIngredient(name: 'Manok', quantity: '1 kg'),
      RecipeIngredient(name: 'Toyo', quantity: '1/2 tasa'),
      RecipeIngredient(name: 'Suka', quantity: '1/4 tasa'),
      RecipeIngredient(name: 'Laurel', quantity: '3 dahon', isOptional: true),
    ],
    instructions: ['Step 1', 'Step 2'],
  );

  test('splits have vs missing by fridge contents', () {
    final match = matchRecipe(recipe, {'manok', 'toyo'});
    expect(match.have.map((i) => i.name), containsAll(['Manok', 'Toyo']));
    expect(match.missing.map((i) => i.name), containsAll(['Suka', 'Laurel']));
  });

  test('isComplete ignores optional ingredients', () {
    // Has all required (manok, toyo, suka) but not the optional laurel.
    final match = matchRecipe(recipe, {'manok', 'toyo', 'suka'});
    expect(match.isComplete, isTrue);
    expect(match.missingRequiredCount, 0);
  });

  test('not complete when a required ingredient is missing', () {
    final match = matchRecipe(recipe, {'manok', 'toyo'});
    expect(match.isComplete, isFalse);
    expect(match.missingRequiredCount, 1); // suka
  });

  test('empty fridge means everything missing', () {
    final match = matchRecipe(recipe, {});
    expect(match.have, isEmpty);
    expect(match.missing.length, 4);
  });
}
