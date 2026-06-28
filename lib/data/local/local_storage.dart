import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/ingredient.dart';
import 'ingredient_adapter.dart';

/// Hive box names. Keep these centralized so providers and init agree.
const String fridgeBoxName = 'fridge';

/// Local "review queue" of dishes users flagged as wrong AI suggestions
/// (PRD §4.3). Untyped box of `{recipeId, at}` maps — no adapter needed.
const String reportsBoxName = 'wrong_dish_reports';

/// Saved/favorited recipe ids, so favorites survive app restarts (like the
/// fridge). Stored as a `Box<String>` keyed by recipe id (value == id).
const String savedBoxName = 'saved_recipes';

/// Weekly meal plan: a `Box<String>` keyed by day ('mon'..'sun') → recipe id.
const String plannerBoxName = 'meal_planner';

/// User-created recipes (ADD ULAM): a `Box<String>` keyed by recipe id, each
/// value a JSON-encoded recipe. JSON strings avoid Hive's nested-map typing.
const String userRecipesBoxName = 'user_recipes';

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
  await Hive.openBox<String>(savedBoxName);
  await Hive.openBox<String>(plannerBoxName);
  await Hive.openBox<String>(userRecipesBoxName);
}

/// The already-open fridge box. Safe to call synchronously anywhere after
/// [initLocalStorage] has completed.
Box<Ingredient> get fridgeBox => Hive.box<Ingredient>(fridgeBoxName);

/// The already-open wrong-dish report box (local review queue).
Box get reportsBox => Hive.box(reportsBoxName);

/// The already-open saved-recipes box (favorited recipe ids).
Box<String> get savedBox => Hive.box<String>(savedBoxName);

/// The already-open meal-planner box (day → recipe id).
Box<String> get plannerBox => Hive.box<String>(plannerBoxName);

/// The already-open user-recipes box (id → JSON-encoded recipe).
Box<String> get userRecipesBox => Hive.box<String>(userRecipesBoxName);
