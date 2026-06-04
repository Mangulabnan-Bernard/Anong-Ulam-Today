import '../../data/models/ingredient.dart';
import '../../data/models/recipe.dart';
import 'dish_suggestion.dart';

/// Contract for the dish-suggestion engine.
///
/// Sprint 5 ships a fully offline [LocalSuggestionService] implementation.
/// The interface is deliberately `async` and provider-agnostic so a real LLM
/// backend (Gemini/OpenAI behind a secure proxy) can drop in later without
/// touching the UI.
abstract interface class AiSuggestionService {
  /// Returns up to [limit] dishes ranked best-first for the given [fridge]
  /// and optional [mealType] (null / [MealType.any] = any meal).
  Future<List<DishSuggestion>> suggest({
    required List<Ingredient> fridge,
    MealType? mealType,
    int limit,
  });
}
