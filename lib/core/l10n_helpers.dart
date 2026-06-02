import 'package:flutter/widgets.dart';

import '../data/models/recipe.dart';
import '../l10n/app_localizations.dart';

/// Convenience getter: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized labels for [MealType].
extension MealTypeL10n on MealType {
  String localized(AppLocalizations l) => switch (this) {
        MealType.breakfast => l.mealBreakfast,
        MealType.lunch => l.mealLunch,
        MealType.dinner => l.mealDinner,
        MealType.any => l.mealAny,
      };
}

/// Localized labels for [Difficulty].
extension DifficultyL10n on Difficulty {
  String localized(AppLocalizations l) => switch (this) {
        Difficulty.easy => l.difficultyEasy,
        Difficulty.medium => l.difficultyMedium,
        Difficulty.hard => l.difficultyHard,
      };
}
