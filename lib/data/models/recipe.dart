/// Meal time a recipe is suitable for.
enum MealType {
  breakfast('Almusal'),
  lunch('Tanghalian'),
  dinner('Hapunan'),
  any('Kahit kailan');

  const MealType(this.label);
  final String label;
}

enum Difficulty {
  easy('Madali'),
  medium('Katamtaman'),
  hard('Mahirap');

  const Difficulty(this.label);
  final String label;
}

/// A recipe ingredient line (name + quantity).
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
    this.isOptional = false,
  });

  final String name;
  final String quantity;
  final bool isOptional;
}

/// Core recipe model.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.mealTypes,
    required this.difficulty,
    required this.cookingTimeMins,
    required this.ingredients,
    required this.instructions,
    this.emoji = '🍲',
    this.rating = 0,
    this.totalSaves = 0,
    this.region = 'Pilipinas',
  });

  final String id;
  final String title;
  final String description;
  final List<MealType> mealTypes;
  final Difficulty difficulty;
  final int cookingTimeMins;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final String emoji;
  final double rating;
  final int totalSaves;
  final String region;
}
