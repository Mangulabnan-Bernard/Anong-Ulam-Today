/// Minimal contract for a text-generating LLM, kept deliberately tiny so the
/// RAG layer doesn't depend on any specific backend.
///
/// The on-device Gemma implementation lives in `gemma_text_generator.dart`.
/// Tests use a fake generator — no model download required.
abstract interface class LlmTextGenerator {
  /// Whether the model is downloaded and loaded, i.e. [generate] can run now.
  /// Callers should fall back to the offline heuristic when this is false.
  Future<bool> isReady();

  /// Generates a completion for [prompt]. [systemInstruction] sets the model's
  /// role/behaviour when the backend supports it.
  Future<String> generate(String prompt, {String? systemInstruction});
}
