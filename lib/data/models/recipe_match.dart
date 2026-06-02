import 'recipe.dart';

/// Result of matching a recipe against the user's fridge.
class RecipeMatch {
  const RecipeMatch({
    required this.recipe,
    required this.have,
    required this.missing,
  });

  final Recipe recipe;
  final List<RecipeIngredient> have;
  final List<RecipeIngredient> missing;

  /// Required (non-optional) ingredients only, for the "cookable" check.
  bool get isComplete =>
      missing.where((i) => !i.isOptional).isEmpty;

  int get missingRequiredCount =>
      missing.where((i) => !i.isOptional).length;

  /// 0.0–1.0 how much of the recipe you already have.
  double get matchRatio {
    if (recipe.ingredients.isEmpty) return 0;
    return have.length / recipe.ingredients.length;
  }
}
