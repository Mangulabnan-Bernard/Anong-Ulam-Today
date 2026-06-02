import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_recipes.dart';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_match.dart';
import 'fridge_provider.dart';

/// All available recipes (mock seed for now).
final recipesProvider = Provider<List<Recipe>>((ref) => kMockRecipes);

/// Matches a single recipe's ingredients against the current fridge by name.
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

/// All recipes matched against the fridge, sorted by best match first.
final matchedRecipesProvider = Provider<List<RecipeMatch>>((ref) {
  final recipes = ref.watch(recipesProvider);
  final fridge = ref.watch(fridgeProvider);
  final fridgeNames =
      fridge.map((i) => i.name.toLowerCase()).toSet();

  final matches =
      recipes.map((r) => matchRecipe(r, fridgeNames)).toList();
  matches.sort((a, b) => b.matchRatio.compareTo(a.matchRatio));
  return matches;
});

/// Only recipes the user can fully cook (all required ingredients present).
/// Returns empty if the fridge is empty.
final cookableRecipesProvider = Provider<List<RecipeMatch>>((ref) {
  final fridge = ref.watch(fridgeProvider);
  if (fridge.isEmpty) return [];
  return ref
      .watch(matchedRecipesProvider)
      .where((m) => m.isComplete)
      .toList();
});

/// Current text search query for the discover screen.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final recipeSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Optional meal-type filter for the discover screen.
class MealFilterNotifier extends Notifier<MealType?> {
  @override
  MealType? build() => null;
  void update(MealType? value) => state = value;
}

final recipeMealFilterProvider =
    NotifierProvider<MealFilterNotifier, MealType?>(MealFilterNotifier.new);

/// Recipes filtered by the active search query + meal filter.
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final all = ref.watch(recipesProvider);
  final query = ref.watch(recipeSearchQueryProvider).toLowerCase().trim();
  final meal = ref.watch(recipeMealFilterProvider);

  return all.where((r) {
    final matchesMeal = meal == null || r.mealTypes.contains(meal);
    final matchesQuery = query.isEmpty ||
        r.title.toLowerCase().contains(query) ||
        r.ingredients.any((i) => i.name.toLowerCase().contains(query));
    return matchesMeal && matchesQuery;
  }).toList();
});

/// IDs of saved/favorited recipes.
class SavedRecipesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    state = state.contains(id)
        ? (state.toSet()..remove(id))
        : (state.toSet()..add(id));
  }

  bool isSaved(String id) => state.contains(id);
}

final savedRecipesProvider =
    NotifierProvider<SavedRecipesNotifier, Set<String>>(SavedRecipesNotifier.new);
