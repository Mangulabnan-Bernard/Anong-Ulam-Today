import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../data/local/local_storage.dart';
import '../../data/mock/mock_ingredients.dart';
import '../../data/models/ingredient.dart';

/// Manages the user's fridge ingredients, persisted to a Hive box keyed by
/// ingredient id so contents survive app restarts (PRD §4.2). The box is
/// opened once in `main()`; this notifier reads it synchronously and mirrors
/// it into [state] so the UI rebuilds on every mutation.
class FridgeNotifier extends Notifier<List<Ingredient>> {
  Box<Ingredient> get _box => fridgeBox;

  @override
  List<Ingredient> build() => _box.values.toList();

  void add(Ingredient ingredient) {
    if (_box.containsKey(ingredient.id)) return;
    _box.put(ingredient.id, ingredient);
    state = _box.values.toList();
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
    if (_box.containsKey(match.id)) return null;
    _box.put(match.id, match);
    state = _box.values.toList();
    return match;
  }

  void remove(Ingredient ingredient) {
    _box.delete(ingredient.id);
    state = _box.values.toList();
  }

  void clear() {
    _box.clear();
    state = [];
  }

  bool has(String id) => _box.containsKey(id);
}

final fridgeProvider =
    NotifierProvider<FridgeNotifier, List<Ingredient>>(FridgeNotifier.new);
