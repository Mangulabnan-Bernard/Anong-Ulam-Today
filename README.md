# Anong Ulam Today? 🍲

AI-powered Filipino recipe assistant. Wala nang *"anong ulam?"* every mealtime.

Built with **Flutter + Dart** — runs on **Android, iOS, at Web**.

## Status: Sprint 1–2 (UI/UX scaffold) ✅

Walang Firebase/AI pa — mock data muna. Lahat ng screen ay navigable at gumagana.

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

### Susunod (per Sprint Plan)
- Sprint 3: Hive local storage para sa fridge
- Sprint 4: 100+ seed recipes (JSON)
- Sprint 5: AI suggestions (Gemini/OpenAI)
- Sprint 6: Firebase + ADD ULAM image upload

## Project Structure

```
lib/
├── main.dart                       # App entry (ProviderScope + MaterialApp.router)
├── core/
│   ├── theme/                      # app_colors.dart, app_theme.dart
│   └── router/                     # app_router.dart (GoRouter)
├── data/
│   ├── models/                     # ingredient.dart, recipe.dart
│   └── mock/                       # mock_ingredients.dart, mock_recipes.dart
└── presentation/
    ├── providers/                  # theme, fridge, recipe (Riverpod)
    ├── screens/                    # splash, home, fridge, discover, planner, add_ulam, recipe_detail, main_scaffold
    └── widgets/                    # time_greeting, meal_type_grid, recipe_card
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
- **go_router** — navigation
- **google_fonts** (Poppins) — typography
- **intl** — localization helpers
