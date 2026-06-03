# Anong Ulam Today? 🍲

AI-powered Filipino recipe assistant. Wala nang *"anong ulam?"* every mealtime.

Built with **Flutter + Dart** — runs on **Android, iOS, at Web**.

## Status: Sprint 1–4 (UI/UX scaffold + offline fridge + recipe catalog) ✅

Sprint 1–4 tapos na. Lahat ng screen ay navigable at gumagana, **persistent ang fridge** (Hive local storage), at may **127 seed recipes** na nilo-load mula sa bundled JSON. Wala pang Firebase/AI — paparating sa Sprint 5–6.

### Tapos na
- ✅ Clean architecture folder structure (`core/`, `data/`, `presentation/`)
- ✅ Riverpod state management
- ✅ GoRouter navigation
- ✅ Pinoy-inspired theme (light + dark mode)
- ✅ Splash screen (animated)
- ✅ 5-tab bottom navigation
- ✅ Home: time-based greeting + 2×2 meal grid + "Kahit Ano!" random + suggested recipes
- ✅ Fridge: add/remove ingredients (chips + searchable picker)
- ✅ Discover: search + meal-type filter + recipe list
- ✅ Recipe Detail: ingredients checklist + step-by-step instructions + save
- ✅ ADD ULAM: dynamic ingredient/step form
- ✅ Meal Planner: weekly grid (placeholder)
- ✅ Hive local storage: persistent fridge na nakaka-survive ng app restart
- ✅ Recipe catalog: 127 Filipino recipes mula sa JSON asset (loader + fallback)

### Susunod (per Sprint Plan)
- Sprint 5: AI suggestions (Gemini/OpenAI)
- Sprint 6: Firebase + ADD ULAM image upload

## Project Structure

```
lib/
├── main.dart                       # App entry (init Hive + load recipes, ProviderScope)
├── core/
│   ├── theme/                      # app_colors.dart, app_theme.dart
│   └── router/                     # app_router.dart (GoRouter)
├── data/
│   ├── models/                     # ingredient.dart, recipe.dart (+ fromJson)
│   ├── local/                      # Hive + recipe_loader.dart (JSON → Recipe)
│   └── mock/                       # mock_ingredients.dart, mock_recipes.dart (fallback)
└── presentation/
    ├── providers/                  # theme, fridge (Hive-backed), recipe (Riverpod)
    ├── screens/                    # splash, home, fridge, discover, planner, add_ulam, recipe_detail, main_scaffold
    └── widgets/                    # time_greeting, meal_type_grid, recipe_card

assets/
└── data/recipes.json               # 127 Filipino seed recipes (Sprint 4)
```

## Pagpapatakbo

```bash
flutter pub get
flutter run            # piliin ang device (phone / Chrome / emulator)
```

Sa Android Studio: piliin ang **main.dart** config + device → ▶ Run.

### Iba pang command
```bash
flutter analyze       # static analysis
flutter test          # unit/widget tests
flutter build apk     # Android release build
flutter build web     # Web build
```

## Tech Stack
- **Flutter** 3.38.5 / **Dart** 3.10.4
- **flutter_riverpod** — state management
- **hive_ce** / **hive_ce_flutter** — offline local storage (persistent fridge)
- **go_router** — navigation
- **google_fonts** (Poppins) — typography
- **intl** — localization helpers
