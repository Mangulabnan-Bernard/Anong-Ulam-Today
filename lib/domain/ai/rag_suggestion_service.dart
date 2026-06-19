import '../../data/models/ingredient.dart';
import '../../data/models/recipe.dart';
import 'ai_suggestion_service.dart';
import 'dish_suggestion.dart';
import 'llm_text_generator.dart';
import 'local_suggestion_service.dart';

/// Retrieval-Augmented Generation (RAG) suggestion engine.
///
/// RAG is a *technique*, not a model: it pairs a retriever with a generator.
///
///   1. RETRIEVE — narrow the 127-recipe catalog down to the dishes the fridge
///      can plausibly make. Reuses the offline [LocalSuggestionService] ranking
///      (which is built on `matchRecipe`), so retrieval is fast and free.
///   2. AUGMENT  — build a compact prompt listing those candidates as context.
///   3. GENERATE — ask the on-device LLM ([LlmTextGenerator], e.g. Gemma) to
///      pick and re-rank the best dishes for this fridge + meal time.
///
/// Because the model only ever chooses from numbers in YOUR catalog, it cannot
/// invent recipes that don't exist. If the model isn't ready, or the call/parse
/// fails, it transparently returns the offline heuristic ranking — suggestions
/// never break and the app still works with no model installed.
class RagSuggestionService implements AiSuggestionService {
  RagSuggestionService({
    required List<Recipe> recipes,
    required LlmTextGenerator generator,
    LocalSuggestionService? fallback,
    this.candidatePool = 12,
  })  : _generator = generator,
        _fallback = fallback ??
            LocalSuggestionService(recipes, thinkingDelay: Duration.zero);

  final LlmTextGenerator _generator;

  /// Offline engine used both for retrieval (the candidate set) and as the
  /// graceful fallback when the LLM is unavailable.
  final LocalSuggestionService _fallback;

  /// How many top heuristic matches to hand the LLM as RAG context.
  final int candidatePool;

  static const String _systemInstruction =
      'You are a Filipino home-cooking assistant. From the numbered list of '
      'candidate dishes, choose the ones that best fit the ingredients on hand '
      'and the meal time. Reply with ONLY the dish numbers in best-first order, '
      'comma-separated (for example: 3,1,5). Do not add any other text.';

  @override
  Future<List<DishSuggestion>> suggest({
    required List<Ingredient> fridge,
    MealType? mealType,
    int limit = 6,
  }) async {
    if (fridge.isEmpty) return const [];

    // 1. RETRIEVE — the offline heuristic's top candidates for this fridge.
    final candidates = await _fallback.suggest(
      fridge: fridge,
      mealType: mealType,
      limit: candidatePool,
    );
    if (candidates.isEmpty) return const [];

    // No model? Return the heuristic ranking as-is.
    if (!await _generator.isReady()) {
      return candidates.take(limit).toList();
    }

    try {
      // 2. AUGMENT + 3. GENERATE.
      final answer = await _generator.generate(
        _buildPrompt(fridge, mealType, candidates),
        systemInstruction: _systemInstruction,
      );
      final ranked = _rankFromAnswer(answer, candidates);
      // If parsing yielded nothing usable, fall back to heuristic order.
      return (ranked.isEmpty ? candidates : ranked).take(limit).toList();
    } catch (_) {
      // Any model/parse failure → graceful offline fallback.
      return candidates.take(limit).toList();
    }
  }

  String _buildPrompt(
    List<Ingredient> fridge,
    MealType? mealType,
    List<DishSuggestion> candidates,
  ) {
    final have = fridge.map((i) => i.name).join(', ');
    final meal = (mealType == null || mealType == MealType.any)
        ? 'any meal'
        : mealType.label;

    final buf = StringBuffer()
      ..writeln('Fridge: $have')
      ..writeln('Meal time: $meal')
      ..writeln('Candidate dishes:');
    for (var i = 0; i < candidates.length; i++) {
      final c = candidates[i];
      buf.writeln(
        '${i + 1}. ${c.recipe.title} — have ${c.haveRequired}/'
        '${c.requiredTotal} key ingredients, ${c.recipe.cookingTimeMins} min',
      );
    }
    buf.write('Which numbers are the best dishes? Numbers only, best first.');
    return buf.toString();
  }

  /// Parses the model's reply (e.g. "3, 1, 5") into a re-ordered suggestion
  /// list. Robust to extra prose: it just extracts 1-based indices, ignores
  /// out-of-range and duplicate numbers, and preserves the model's order.
  List<DishSuggestion> _rankFromAnswer(
    String answer,
    List<DishSuggestion> candidates,
  ) {
    final ordered = <DishSuggestion>[];
    final seen = <int>{};
    for (final m in RegExp(r'\d+').allMatches(answer)) {
      final idx = int.parse(m.group(0)!) - 1;
      if (idx >= 0 && idx < candidates.length && seen.add(idx)) {
        ordered.add(candidates[idx]);
      }
    }
    return ordered;
  }
}
