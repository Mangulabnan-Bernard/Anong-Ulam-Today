import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../data/local/local_storage.dart';

/// Stable day keys for the weekly planner (Mon → Sun). The UI maps these to
/// localized labels; storage keys stay language-independent.
const List<String> plannerDayKeys = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

/// The weekly meal plan as a `{ dayKey: recipeId }` map, persisted to Hive so
/// it survives restarts. Falls back to in-memory state when the box isn't open
/// (e.g. in pure-UI widget tests).
class PlannerNotifier extends Notifier<Map<String, String>> {
  Box<String>? get _box =>
      Hive.isBoxOpen(plannerBoxName) ? plannerBox : null;

  Map<String, String> _snapshot(Box<String> box) => {
        for (final key in box.keys) key as String: box.get(key)!,
      };

  @override
  Map<String, String> build() {
    final box = _box;
    return box == null ? <String, String>{} : _snapshot(box);
  }

  /// Assigns [recipeId] to [dayKey] (overwrites any existing meal that day).
  void setMeal(String dayKey, String recipeId) {
    final box = _box;
    if (box != null) {
      box.put(dayKey, recipeId);
      state = _snapshot(box);
    } else {
      state = {...state, dayKey: recipeId};
    }
  }

  /// Clears the meal planned for [dayKey].
  void removeMeal(String dayKey) {
    final box = _box;
    if (box != null) {
      box.delete(dayKey);
      state = _snapshot(box);
    } else {
      state = {...state}..remove(dayKey);
    }
  }
}

final plannerProvider =
    NotifierProvider<PlannerNotifier, Map<String, String>>(
  PlannerNotifier.new,
);
