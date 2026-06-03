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

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'] as String,
        quantity: (json['quantity'] as String?) ?? '',
        isOptional: (json['optional'] as bool?) ?? false,
      );

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

  /// Builds a [Recipe] from a decoded JSON map (see assets/data/recipes.json).
  /// Unknown meal-type / difficulty keys fall back to sensible defaults so a
  /// typo in the seed file degrades gracefully instead of crashing the app.
  factory Recipe.fromJson(Map<String, dynamic> json) {
    final mealKeys = (json['mealTypes'] as List<dynamic>? ?? const [])
        .map((e) => e as String);
    final mealTypes = mealKeys
        .map(
          (k) => MealType.values.firstWhere(
            (m) => m.name == k,
            orElse: () => MealType.any,
          ),
        )
        .toList();

    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      mealTypes: mealTypes.isEmpty ? const [MealType.any] : mealTypes,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      cookingTimeMins: (json['cookingTimeMins'] as num?)?.toInt() ?? 0,
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      emoji: (json['emoji'] as String?) ?? '🍲',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalSaves: (json['totalSaves'] as num?)?.toInt() ?? 0,
      region: (json['region'] as String?) ?? 'Pilipinas',
    );
  }

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
