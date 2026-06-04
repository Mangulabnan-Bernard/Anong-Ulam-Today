import '../data/models/recipe.dart';
import '../data/models/recipe_match.dart';

/// Matches a single recipe's ingredients against the current fridge by name.
/// Pure function (no Flutter/Riverpod deps) so it can be reused by the
/// suggestion engine and unit-tested in isolation.
///
/// [fridgeNames] is the set of lowercased ingredient names in the fridge.
RecipeMatch matchRecipe(Recipe recipe, Set<String> fridgeNames) {
  final have = <RecipeIngredient>[];
  final missing = <RecipeIngredient>[];
  for (final ing in recipe.ingredients) {
    final name = ing.name.toLowerCase();
    final inFridge = fridgeNames.any(
      (f) => name.contains(f) || f.contains(name),
    );
    (inFridge ? have : missing).add(ing);
  }
  return RecipeMatch(recipe: recipe, have: have, missing: missing);
}
