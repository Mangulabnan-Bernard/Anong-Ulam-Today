import '../../data/models/recipe.dart';
import '../../data/models/recipe_match.dart';

/// One AI-ranked dish suggestion: a fridge [match] plus a 0–1 confidence
/// [score]. Mirrors the PRD AI contract (has[] / missing[] / time) while
/// staying UI-friendly.
class DishSuggestion {
  const DishSuggestion({required this.match, required this.score});

  final RecipeMatch match;

  /// 0.0–1.0 — how strongly the engine recommends this dish for the current
  /// fridge + meal time.
  final double score;

  Recipe get recipe => match.recipe;

  /// Required ingredients you already have / total required.
  int get haveRequired => match.haveRequiredCount;
  int get requiredTotal => match.requiredCount;

  int get confidencePercent => (score * 100).round();
}
