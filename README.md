# Anong Ulam Today? 🍲

AI-powered Filipino recipe assistant. Wala nang *"anong ulam?"* every mealtime.

Built with **Flutter + Dart** — runs on **Android, iOS, at Web**.

## Status: Sprint 1–5 (scaffold + offline fridge + recipe catalog + AI suggestions) ✅

Sprint 1–5 tapos na. **Persistent ang fridge** (Hive), may **127 seed recipes** mula sa JSON, at may **AI Suggestions** na nagra-rank ng ulam base sa laman ng ref + meal time — **fully offline**, walang API key. Naka-abstract sa `AiSuggestionService` para pwedeng saksakan ng totoong LLM sa Sprint 6. Wala pang Firebase.

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
- ✅ AI Suggestions: offline ranking engine (fridge + meal time → ranked dishes na may confidence %, has/missing, "report wrong dish" → local review queue). Swappable `AiSuggestionService` interface

### Susunod (per Sprint Plan)
- Sprint 6: Real LLM (Gemini/OpenAI) sa likod ng `AiSuggestionService` + Firebase + ADD ULAM image upload

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
├── domain/                         # recipe_matching.dart + ai/ (suggestion engine)
│   └── ai/                         # AiSuggestionService + LocalSuggestionService
└── presentation/
    ├── providers/                  # theme, fridge, recipe, ai_suggestion (Riverpod)
    ├── screens/                    # splash, home, fridge, discover, ai_suggest, planner, add_ulam, recipe_detail
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
