// Unit tests for the Sprint 6 RAG suggestion engine. A fake LlmTextGenerator
// stands in for on-device Gemma, so these run with no model download.
import 'package:anong_ulam_today/data/models/ingredient.dart';
import 'package:anong_ulam_today/data/models/recipe.dart';
import 'package:anong_ulam_today/domain/ai/llm_text_generator.dart';
import 'package:anong_ulam_today/domain/ai/rag_suggestion_service.dart';
import 'package:flutter_test/flutter_test.dart';

Ingredient _ing(String id) =>
    Ingredient(id: id, name: id, nameEn: id, category: IngredientCategory.iba);

const _adobo = Recipe(
  id: 'adobo',
  title: 'Adobo',
  description: '',
  mealTypes: [MealType.lunch, MealType.dinner],
  difficulty: Difficulty.easy,
  cookingTimeMins: 45,
  rating: 4.8,
  ingredients: [
    RecipeIngredient(name: 'Manok', quantity: '1 kg'),
    RecipeIngredient(name: 'Toyo', quantity: '1/2 tasa'),
    RecipeIngredient(name: 'Suka', quantity: '1/4 tasa'),
    RecipeIngredient(name: 'Bawang', quantity: '6 cloves'),
  ],
  instructions: ['a'],
);

const _tinola = Recipe(
  id: 'tinola',
  title: 'Tinola',
  description: '',
  mealTypes: [MealType.lunch],
  difficulty: Difficulty.easy,
  cookingTimeMins: 40,
  rating: 4.5,
  ingredients: [
    RecipeIngredient(name: 'Manok', quantity: '1 kg'),
    RecipeIngredient(name: 'Luya', quantity: '1'),
    RecipeIngredient(name: 'Sayote', quantity: '1'),
  ],
  instructions: ['a'],
);

const _recipes = [_adobo, _tinola];

/// Fake generator that records the prompt and replies with [reply].
class _FakeLlm implements LlmTextGenerator {
  _FakeLlm({required this.reply, this.ready = true});

  final String reply;
  final bool ready;
  String? lastPrompt;

  @override
  Future<bool> isReady() async => ready;

  @override
  Future<String> generate(String prompt, {String? systemInstruction}) async {
    lastPrompt = prompt;
    return reply;
  }
}

/// Generator that always throws — exercises the error fallback path.
class _ThrowingLlm implements LlmTextGenerator {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<String> generate(String prompt, {String? systemInstruction}) async {
    throw StateError('model boom');
  }
}

RagSuggestionService _rag(LlmTextGenerator gen) =>
    RagSuggestionService(recipes: _recipes, generator: gen);

void main() {
  final fullFridge = [
    _ing('Manok'),
    _ing('Toyo'),
    _ing('Suka'),
    _ing('Bawang'),
    _ing('Luya'),
    _ing('Sayote'),
  ];

  test('empty fridge yields no suggestions (no LLM call)', () async {
    final llm = _FakeLlm(reply: '1,2');
    final out = await _rag(llm).suggest(fridge: const []);
    expect(out, isEmpty);
    expect(llm.lastPrompt, isNull);
  });

  test('LLM re-ranks the retrieved candidates by the numbers it returns',
      () async {
    // Heuristic would rank adobo (complete) first; LLM votes tinola first.
    final llm = _FakeLlm(reply: '2, 1');
    final out = await _rag(llm).suggest(fridge: fullFridge);
    expect(out.map((s) => s.recipe.id).toList(), ['tinola', 'adobo']);
    // The prompt is grounded in the real catalog (RAG augmentation).
    expect(llm.lastPrompt, contains('Adobo'));
    expect(llm.lastPrompt, contains('Tinola'));
  });

  test('garbage reply falls back to heuristic order', () async {
    final out = await _rag(_FakeLlm(reply: 'no numbers here')).suggest(
      fridge: fullFridge,
    );
    expect(out.first.recipe.id, 'adobo'); // heuristic ranking preserved
  });

  test('out-of-range / duplicate indices are ignored', () async {
    final out = await _rag(_FakeLlm(reply: '99, 2, 2, 0, 1')).suggest(
      fridge: fullFridge,
    );
    expect(out.map((s) => s.recipe.id).toList(), ['tinola', 'adobo']);
  });

  test('not-ready model returns heuristic ranking without generating',
      () async {
    final llm = _FakeLlm(reply: '2,1', ready: false);
    final out = await _rag(llm).suggest(fridge: fullFridge);
    expect(out.first.recipe.id, 'adobo');
    expect(llm.lastPrompt, isNull);
  });

  test('generator error falls back to heuristic instead of throwing',
      () async {
    final out = await _rag(_ThrowingLlm()).suggest(fridge: fullFridge);
    expect(out.first.recipe.id, 'adobo');
  });
}
