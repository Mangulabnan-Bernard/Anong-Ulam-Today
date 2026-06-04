import '../../data/models/ingredient.dart';
import '../../data/models/recipe.dart';
import '../recipe_matching.dart';
import 'ai_suggestion_service.dart';
import 'dish_suggestion.dart';

/// Offline suggestion engine: ranks the seed catalog against the fridge with a
/// transparent scoring heuristic. No network, no API key — works inside the
/// downloadable APK. Swappable for a real LLM via [AiSuggestionService].
class LocalSuggestionService implements AiSuggestionService {
  LocalSuggestionService(this._recipes, {this.thinkingDelay = defaultDelay});

  final List<Recipe> _recipes;

  /// Small artificial delay so the UI can show a "thinking" state, matching
  /// the latency profile of a real LLM call. Set to [Duration.zero] in tests.
  final Duration thinkingDelay;

  static const Duration defaultDelay = Duration(milliseconds: 450);

  @override
  Future<List<DishSuggestion>> suggest({
    required List<Ingredient> fridge,
    MealType? mealType,
    int limit = 6,
  }) async {
    if (thinkingDelay > Duration.zero) {
      await Future<void>.delayed(thinkingDelay);
    }
    if (fridge.isEmpty) return const [];

    final fridgeNames = fridge.map((i) => i.name.toLowerCase()).toSet();
    final wantsMeal = mealType != null && mealType != MealType.any;

    final scored = <DishSuggestion>[];
    for (final recipe in _recipes) {
      if (wantsMeal &&
          !recipe.mealTypes.contains(mealType) &&
          !recipe.mealTypes.contains(MealType.any)) {
        continue;
      }

      final match = matchRecipe(recipe, fridgeNames);
      // Skip dishes you have none of the core ingredients for — irrelevant.
      if (match.haveRequiredCount <= 0) continue;

      final ratio = match.requiredCount == 0
          ? 1.0
          : match.haveRequiredCount / match.requiredCount;

      var score = ratio * 0.70 +
          (match.isComplete ? 0.15 : 0.0) +
          (recipe.rating / 5.0) * 0.10 +
          (wantsMeal && recipe.mealTypes.contains(mealType) ? 0.05 : 0.0);
      score = score.clamp(0.0, 1.0);

      scored.add(DishSuggestion(match: match, score: score));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      // Tie-break: fewer missing required, then higher rating.
      final byMissing = a.match.missingRequiredCount
          .compareTo(b.match.missingRequiredCount);
      if (byMissing != 0) return byMissing;
      return b.recipe.rating.compareTo(a.recipe.rating);
    });

    return scored.take(limit).toList();
  }
}
