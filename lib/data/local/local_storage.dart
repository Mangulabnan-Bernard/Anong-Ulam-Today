import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/ingredient.dart';
import 'ingredient_adapter.dart';

/// Hive box names. Keep these centralized so providers and init agree.
const String fridgeBoxName = 'fridge';

/// Local "review queue" of dishes users flagged as wrong AI suggestions
/// (PRD §4.3). Untyped box of `{recipeId, at}` maps — no adapter needed.
const String reportsBoxName = 'wrong_dish_reports';

/// One-time Hive bootstrap: init the engine, register adapters, and open the
/// boxes the app reads synchronously later. Call once in `main()` before
/// `runApp`, after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> initLocalStorage() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(IngredientAdapter().typeId)) {
    Hive.registerAdapter(IngredientAdapter());
  }

  await Hive.openBox<Ingredient>(fridgeBoxName);
  await Hive.openBox(reportsBoxName);
}

/// The already-open fridge box. Safe to call synchronously anywhere after
/// [initLocalStorage] has completed.
Box<Ingredient> get fridgeBox => Hive.box<Ingredient>(fridgeBoxName);

/// The already-open wrong-dish report box (local review queue).
Box get reportsBox => Hive.box(reportsBoxName);
