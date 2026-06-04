import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_storage.dart';
import '../../data/models/recipe.dart';
import '../../domain/ai/ai_suggestion_service.dart';
import '../../domain/ai/dish_suggestion.dart';
import '../../domain/ai/local_suggestion_service.dart';
import 'fridge_provider.dart';
import 'recipe_provider.dart';

/// The active suggestion engine. Local + offline for now; swap this single
/// override to plug in a real LLM-backed service later.
final aiSuggestionServiceProvider = Provider<AiSuggestionService>((ref) {
  return LocalSuggestionService(ref.watch(recipesProvider));
});

/// Ranked dish suggestions for the given [mealType] (null = any meal),
/// recomputed whenever the fridge changes. Exposes loading/error/data via
/// [AsyncValue] so the UI can show a "thinking" state.
final aiSuggestionsProvider =
    FutureProvider.family<List<DishSuggestion>, MealType?>((ref, mealType) {
  final service = ref.watch(aiSuggestionServiceProvider);
  final fridge = ref.watch(fridgeProvider);
  return service.suggest(fridge: fridge, mealType: mealType);
});

/// Records a "wrong dish" report to the local review queue (Hive). Returns the
/// number of reports stored so far. Mirrors the PRD's review-queue concept
/// without a backend.
Future<int> reportWrongDish(String recipeId) async {
  await reportsBox.add({
    'recipeId': recipeId,
    'at': DateTime.now().toIso8601String(),
  });
  return reportsBox.length;
}
