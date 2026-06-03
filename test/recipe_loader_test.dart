// Validates the Sprint 4 seed catalog: the bundled JSON loads, parses, and
// holds 100+ well-formed recipes. Also covers the parser's edge cases.
import 'package:anong_ulam_today/data/local/recipe_loader.dart';
import 'package:anong_ulam_today/data/models/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('seed catalog asset', () {
    test('bundles at least 100 recipes', () async {
      final recipes = await loadSeedRecipes();
      expect(recipes.length, greaterThanOrEqualTo(100));
    });

    test('every recipe has unique id, title, ingredients, and steps', () async {
      final recipes = await loadSeedRecipes();
      final ids = recipes.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'ids must be unique');

      for (final r in recipes) {
        expect(r.id, isNotEmpty);
        expect(r.title, isNotEmpty);
        expect(r.ingredients, isNotEmpty, reason: '${r.id} has no ingredients');
        expect(r.instructions, isNotEmpty, reason: '${r.id} has no steps');
        expect(r.mealTypes, isNotEmpty, reason: '${r.id} has no meal types');
        expect(r.cookingTimeMins, greaterThan(0), reason: '${r.id} time');
      }
    });
  });

  group('parseRecipesJson', () {
    test('parses a wrapped { "recipes": [...] } document', () {
      const json = '''
      {"recipes":[
        {"id":"x","title":"Test Ulam","mealTypes":["lunch"],
         "difficulty":"medium","cookingTimeMins":25,
         "ingredients":[{"name":"Manok","quantity":"1 kg"},
                        {"name":"Toyo","quantity":"2 kutsara","optional":true}],
         "instructions":["Lutuin.","Ihain."]}
      ]}''';
      final recipes = parseRecipesJson(json);
      expect(recipes, hasLength(1));
      final r = recipes.single;
      expect(r.id, 'x');
      expect(r.mealTypes, [MealType.lunch]);
      expect(r.difficulty, Difficulty.medium);
      expect(r.ingredients[1].isOptional, isTrue);
    });

    test('parses a bare top-level array', () {
      const json =
          '[{"id":"y","title":"Y","mealTypes":["any"],"difficulty":"easy",'
          '"cookingTimeMins":5,"ingredients":[{"name":"Asin","quantity":"k"}],'
          '"instructions":["a"]}]';
      expect(parseRecipesJson(json).single.id, 'y');
    });

    test('unknown enum keys fall back to safe defaults', () {
      const json =
          '[{"id":"z","title":"Z","mealTypes":["brunch"],"difficulty":"extreme",'
          '"cookingTimeMins":5,"ingredients":[{"name":"Asin","quantity":"k"}],'
          '"instructions":["a"]}]';
      final r = parseRecipesJson(json).single;
      expect(r.mealTypes, [MealType.any]);
      expect(r.difficulty, Difficulty.easy);
    });

    test('empty list falls back to the bundled mock recipes', () {
      final recipes = parseRecipesJson('{"recipes":[]}');
      expect(recipes, isNotEmpty);
    });
  });
}
