import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/ingredient.dart';
import 'ingredient_adapter.dart';

/// Hive box names. Keep these centralized so providers and init agree.
const String fridgeBoxName = 'fridge';

/// One-time Hive bootstrap: init the engine, register adapters, and open the
/// boxes the app reads synchronously later. Call once in `main()` before
/// `runApp`, after `WidgetsFlutterBinding.ensureInitialized()`.
Future<void> initLocalStorage() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(IngredientAdapter().typeId)) {
    Hive.registerAdapter(IngredientAdapter());
  }

  await Hive.openBox<Ingredient>(fridgeBoxName);
}

/// The already-open fridge box. Safe to call synchronously anywhere after
/// [initLocalStorage] has completed.
Box<Ingredient> get fridgeBox => Hive.box<Ingredient>(fridgeBoxName);
