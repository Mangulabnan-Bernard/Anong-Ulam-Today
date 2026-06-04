// Unit tests for the Sprint 5 offline suggestion engine.
import 'package:anong_ulam_today/data/models/ingredient.dart';
import 'package:anong_ulam_today/data/models/recipe.dart';
import 'package:anong_ulam_today/domain/ai/local_suggestion_service.dart';
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

const _champorado = Recipe(
  id: 'champorado',
  title: 'Champorado',
  description: '',
  mealTypes: [MealType.breakfast],
  difficulty: Difficulty.easy,
  cookingTimeMins: 30,
  rating: 4.6,
  ingredients: [
    RecipeIngredient(name: 'Malagkit', quantity: '1 tasa'),
    RecipeIngredient(name: 'Tablea', quantity: '4'),
  ],
  instructions: ['a'],
);

LocalSuggestionService _service() => LocalSuggestionService(
      const [_adobo, _tinola, _champorado],
      thinkingDelay: Duration.zero,
    );

void main() {
  test('empty fridge yields no suggestions', () async {
    final out = await _service().suggest(fridge: const []);
    expect(out, isEmpty);
  });

  test('ranks the more-complete dish first', () async {
    final out = await _service().suggest(
      fridge: [_ing('Manok'), _ing('Toyo'), _ing('Suka'), _ing('Bawang')],
    );
    expect(out.first.recipe.id, 'adobo');
    // Adobo is fully cookable → higher confidence than partial tinola.
    final tinola = out.firstWhere((s) => s.recipe.id == 'tinola');
    expect(out.first.score, greaterThan(tinola.score));
  });

  test('skips dishes you have none of the core ingredients for', () async {
    final out = await _service().suggest(fridge: [_ing('Manok')]);
    final ids = out.map((s) => s.recipe.id);
    expect(ids, contains('adobo'));
    expect(ids, contains('tinola'));
    expect(ids, isNot(contains('champorado'))); // no malagkit/tablea
  });

  test('meal-type filter excludes other meals', () async {
    final out = await _service().suggest(
      fridge: [_ing('Manok'), _ing('Malagkit'), _ing('Tablea')],
      mealType: MealType.breakfast,
    );
    expect(out.map((s) => s.recipe.id), ['champorado']);
  });

  test('confidence is a sane 0–100 and complete dish is high', () async {
    final out = await _service().suggest(
      fridge: [_ing('Manok'), _ing('Toyo'), _ing('Suka'), _ing('Bawang')],
    );
    final adobo = out.first;
    expect(adobo.confidencePercent, inInclusiveRange(0, 100));
    expect(adobo.confidencePercent, greaterThanOrEqualTo(80));
    expect(adobo.haveRequired, 4);
    expect(adobo.requiredTotal, 4);
  });

  test('limit caps the number of suggestions', () async {
    final out = await _service().suggest(
      fridge: [_ing('Manok'), _ing('Toyo'), _ing('Suka'), _ing('Bawang')],
      limit: 1,
    );
    expect(out, hasLength(1));
  });
}
