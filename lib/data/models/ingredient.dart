/// Ingredient categories used across the app.
enum IngredientCategory {
  gulay('Gulay'),
  karne('Karne'),
  isda('Isda / Seafood'),
  pampalasa('Pampalasa'),
  pananghalian('Carbs / Grains'),
  iba('Iba pa');

  const IngredientCategory(this.label);
  final String label;
}

/// A single ingredient. TL name is primary; EN name aids search.
class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    this.emoji = '🥘',
  });

  final String id;
  final String name; // Tagalog, e.g. "bawang"
  final String nameEn; // English, e.g. "garlic"
  final IngredientCategory category;
  final String emoji;

  @override
  bool operator ==(Object other) =>
      other is Ingredient && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
