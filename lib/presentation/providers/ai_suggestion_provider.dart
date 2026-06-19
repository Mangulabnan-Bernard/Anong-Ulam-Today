import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_storage.dart';
import '../../data/models/recipe.dart';
import '../../domain/ai/ai_suggestion_service.dart';
import '../../domain/ai/dish_suggestion.dart';
import '../../domain/ai/gemma_text_generator.dart';
import '../../domain/ai/local_suggestion_service.dart';
import '../../domain/ai/rag_suggestion_service.dart';
import 'fridge_provider.dart';
import 'recipe_provider.dart';

/// Shared on-device Gemma generator (Sprint 6). One instance for the whole app;
/// disposed with the provider scope.
final gemmaGeneratorProvider = Provider<GemmaTextGenerator>((ref) {
  final generator = GemmaTextGenerator();
  ref.onDispose(() => generator.dispose());
  return generator;
});

/// Whether the AI-powered (RAG + Gemma) engine is enabled. Off by default: the
/// app works fully offline with the heuristic until the user opts in and the
/// ~550 MB model is downloaded.
class UseRagEngineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final useRagEngineProvider =
    NotifierProvider<UseRagEngineNotifier, bool>(UseRagEngineNotifier.new);

/// Lifecycle of the on-device Gemma model from the UI's point of view.
enum GemmaPhase { idle, downloading, loading, ready, error }

/// Snapshot of the model download/load for the UI (progress + errors).
class GemmaDownloadState {
  const GemmaDownloadState({
    this.phase = GemmaPhase.idle,
    this.percent = 0,
    this.error,
  });

  final GemmaPhase phase;
  final int percent;
  final String? error;

  bool get isBusy =>
      phase == GemmaPhase.downloading || phase == GemmaPhase.loading;
}

/// Drives the one-time model download + load, then flips on the RAG engine.
/// The ~550 MB download happens here (with progress) the first time the user
/// enables Smart AI; afterwards the model is cached on the device.
class GemmaDownloadNotifier extends Notifier<GemmaDownloadState> {
  @override
  GemmaDownloadState build() => const GemmaDownloadState();

  Future<void> enable() async {
    final generator = ref.read(gemmaGeneratorProvider);
    try {
      state = const GemmaDownloadState(phase: GemmaPhase.downloading);
      await generator.ensureInstalled(
        onProgress: (percent) => state = GemmaDownloadState(
          phase: GemmaPhase.downloading,
          percent: percent,
        ),
      );
      state = const GemmaDownloadState(phase: GemmaPhase.loading);
      await generator.warmUp();
      state = const GemmaDownloadState(phase: GemmaPhase.ready);
      ref.read(useRagEngineProvider.notifier).set(true);
    } catch (e) {
      state = GemmaDownloadState(phase: GemmaPhase.error, error: '$e');
    }
  }

  /// Turn Smart AI back off (keeps the downloaded model on disk).
  void disable() {
    ref.read(useRagEngineProvider.notifier).set(false);
    state = const GemmaDownloadState();
  }
}

final gemmaDownloadProvider =
    NotifierProvider<GemmaDownloadNotifier, GemmaDownloadState>(
  GemmaDownloadNotifier.new,
);

/// The active suggestion engine. Offline heuristic by default; switches to the
/// RAG + Gemma engine when [useRagEngineProvider] is on. The RAG engine itself
/// falls back to the heuristic whenever the model isn't ready, so suggestions
/// never break.
final aiSuggestionServiceProvider = Provider<AiSuggestionService>((ref) {
  final recipes = ref.watch(recipesProvider);
  if (ref.watch(useRagEngineProvider)) {
    return RagSuggestionService(
      recipes: recipes,
      generator: ref.watch(gemmaGeneratorProvider),
    );
  }
  return LocalSuggestionService(recipes);
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
