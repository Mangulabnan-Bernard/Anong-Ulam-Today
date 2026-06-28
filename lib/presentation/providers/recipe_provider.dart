import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../data/local/local_storage.dart';
import '../../data/mock/mock_recipes.dart';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_match.dart';
import '../../domain/recipe_matching.dart';
import 'fridge_provider.dart';

// Re-exported so existing imports (`recipe_provider.dart`) still resolve
// `matchRecipe`; the implementation now lives in the domain layer.
export '../../domain/recipe_matching.dart' show matchRecipe;

/// All available recipes. Defaults to the small mock seed; overridden in
/// `main()` with the full JSON catalog (Sprint 4).
final recipesProvider = Provider<List<Recipe>>((ref) => kMockRecipes);

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

/// IDs of saved/favorited recipes, persisted to Hive so favorites survive an
/// app restart. Falls back to in-memory state when the box isn't open (e.g. in
/// pure-UI widget tests), so the UI never depends on storage being initialized.
class SavedRecipesNotifier extends Notifier<Set<String>> {
  Box<String>? get _box =>
      Hive.isBoxOpen(savedBoxName) ? savedBox : null;

  @override
  Set<String> build() => _box?.values.toSet() ?? <String>{};

  void toggle(String id) {
    final box = _box;
    if (box != null) {
      if (box.containsKey(id)) {
        box.delete(id);
      } else {
        box.put(id, id);
      }
      state = box.values.toSet();
    } else {
      state = state.contains(id)
          ? (state.toSet()..remove(id))
          : (state.toSet()..add(id));
    }
  }

  bool isSaved(String id) => state.contains(id);
}

final savedRecipesProvider =
    NotifierProvider<SavedRecipesNotifier, Set<String>>(SavedRecipesNotifier.new);
