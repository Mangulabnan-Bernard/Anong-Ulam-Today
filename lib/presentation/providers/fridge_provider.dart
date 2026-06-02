import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_ingredients.dart';
import '../../data/models/ingredient.dart';

/// Manages the user's fridge ingredients. In-memory mock store for now —
/// swap the backing store for Hive in the Offline sprint.
class FridgeNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() => [];

  void add(Ingredient ingredient) {
    if (state.any((i) => i.id == ingredient.id)) return;
    state = [...state, ingredient];
  }

  /// Adds an ingredient by (fuzzy) name. Matches against the common-ingredient
  /// catalog; falls back to a free-text ingredient. Returns the added item,
  /// or null if it was already in the fridge.
  Ingredient? addByName(String rawName) {
    final name = rawName.toLowerCase().trim();
    final match = kCommonIngredients.firstWhere(
      (i) =>
          name.contains(i.name.toLowerCase()) ||
          i.name.toLowerCase().contains(name) ||
          name.contains(i.nameEn.toLowerCase()),
      orElse: () => Ingredient(
        id: 'custom_${name.replaceAll(' ', '_')}',
        name: rawName,
        nameEn: rawName,
        category: IngredientCategory.iba,
      ),
    );
    if (state.any((i) => i.id == match.id)) return null;
    state = [...state, match];
    return match;
  }

  void remove(Ingredient ingredient) {
    state = state.where((i) => i.id != ingredient.id).toList();
  }

  void clear() => state = [];

  bool has(String id) => state.any((i) => i.id == id);
}

final fridgeProvider =
    NotifierProvider<FridgeNotifier, List<Ingredient>>(FridgeNotifier.new);
