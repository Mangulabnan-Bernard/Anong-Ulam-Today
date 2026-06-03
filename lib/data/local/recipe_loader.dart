import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../mock/mock_recipes.dart';
import '../models/recipe.dart';

/// Path to the bundled seed-recipe catalog (Sprint 4).
const String kRecipesAsset = 'assets/data/recipes.json';

/// Loads the seed recipes from the bundled JSON asset and parses them into
/// [Recipe] models. Falls back to [kMockRecipes] if the asset is missing or
/// malformed, so the app always has something to show.
Future<List<Recipe>> loadSeedRecipes() async {
  try {
    final raw = await rootBundle.loadString(kRecipesAsset);
    return parseRecipesJson(raw);
  } catch (_) {
    return kMockRecipes;
  }
}

/// Parses a recipes JSON document (a top-level list, or `{ "recipes": [...] }`)
/// into [Recipe] models. Exposed separately so it can be unit-tested without
/// an asset bundle. Falls back to [kMockRecipes] if the payload is empty.
List<Recipe> parseRecipesJson(String source) {
  final decoded = jsonDecode(source);
  final list = decoded is Map<String, dynamic>
      ? (decoded['recipes'] as List<dynamic>)
      : decoded as List<dynamic>;

  final recipes = list
      .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
      .toList();

  return recipes.isEmpty ? kMockRecipes : recipes;
}
