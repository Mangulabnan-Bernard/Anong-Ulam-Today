# Anong Ulam Today? 🍲

AI-powered Filipino recipe assistant. Wala nang *"anong ulam?"* every mealtime.

Built with **Flutter + Dart** — runs on **Android, iOS, at Web**.

## Status: Sprint 1–6 (scaffold + offline fridge + recipe catalog + AI suggestions + on-device LLM RAG) ✅

Sprint 1–6 tapos na. **Persistent ang fridge** (Hive), may **127 seed recipes** mula sa JSON, at may **AI Suggestions** na nagra-rank ng ulam base sa laman ng ref + meal time — **fully offline**, walang API key. Sa **Sprint 6**, may **on-device LLM (Gemma 3 1B) na RAG** na engine na — libre, offline, walang API key, walang per-message na bayad. Wala pang Firebase.

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
- ✅ **Sprint 6 — On-device LLM RAG**: `RagSuggestionService` na (1) **kumukuha** ng top candidates mula sa 127 recipes gamit ang heuristic, (2) ginagawang prompt, (3) ipinapasa sa **Gemma 3 1B** on-device (`flutter_gemma`) para i-rerank. Dahil numbers lang sa iyong catalog ang pinipili ng model, **hindi siya nakakaimbento** ng recipe. Graceful fallback sa heuristic kapag walang model — kaya hindi kailanman nasisira ang suggestions. **Libre, offline, walang API key.** Opt-in (off by default); ang `LlmTextGenerator` interface ang naghihiwalay sa Gemma sa RAG logic
- ✅ **Smart AI toggle + download UI** sa AI Suggest screen: Switch para i-on ang Gemma → one-time ~550MB download na may progress bar → tumatakbo offline pagkatapos. `GemmaDownloadNotifier` ang humahawak sa download/load lifecycle

### Susunod (per Sprint Plan)
- Sprint 6 (natitira): **device testing** — i-run sa totoong phone gamit `--dart-define=HUGGINGFACE_TOKEN=...` para i-verify ang Gemma inference (di pa na-test sa device)
- Sprint 7: Firebase + ADD ULAM image upload

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
│   └── ai/                         # AiSuggestionService, LocalSuggestionService,
│                                   #   RagSuggestionService (RAG), LlmTextGenerator
│                                   #   + GemmaTextGenerator (on-device Gemma)
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
- **flutter_gemma** / **flutter_gemma_litertlm** — on-device LLM (Gemma 3 1B) for RAG suggestions
- **go_router** — navigation
- **google_fonts** (Poppins) — typography
- **intl** — localization helpers
