# Anong Ulam Today? — Product Requirements Document

| | |
|---|---|
| **Product** | Anong Ulam Today? |
| **Version** | 2.0 (Production) |
| **Platform** | iOS / Android (cross-platform) |
| **Language** | Taglish (Tagalog + English) |
| **Status** | Draft for engineering review |
| **Last Updated** | June 1, 2026 |
| **Owner** | Product |

---

## 1. Overview

### 1.1 Problem Statement
Every Filipino household faces the same daily friction: *"Anong ulam?"* Deciding what to cook is slowed by decision fatigue, limited ingredients on hand, tight budgets, and recipe sources scattered across blogs and social media. Existing recipe apps are Western-centric and ignore Filipino dishes, ingredient names, and cooking context.

### 1.2 Vision
> Wala nang "Anong ulam?" every mealtime.

An AI-powered recipe assistant that recommends Filipino dishes based on time of day, ingredients already in the user's kitchen, and mood — backed by a community-grown recipe database.

### 1.3 Goals & Non-Goals

**Goals**
- Reduce mealtime decision time to under 30 seconds.
- Suggest cookable dishes from ingredients the user already has.
- Build a community-sourced library of Filipino recipes.

**Non-Goals (v1)**
- Grocery delivery / e-commerce integration.
- Nutrition tracking and calorie counting.
- Video tutorials and live cooking sessions.
- Social feed / following mechanics beyond recipe contribution.

---

## 2. Target Users & Personas

| Persona | Age | Context | Primary Need |
|---|---|---|---|
| **Mommy Lyn** | 35 | Cooks daily for family | Fast suggestions using leftover ingredients |
| **Joshua** | 22 | Student, dorm, low budget | Simple, cheap dishes with minimal equipment |
| **OFW Gina** | 40 | Abroad, misses home cooking | Filipino recipes adaptable to limited local ingredients |
| **Chef Miguel** | 28 | Hobbyist home cook | Contribute and share original recipes |

---

## 3. User Stories

### Epic 1 — Meal Decision Helper
| ID | Story | Priority |
|---|---|---|
| US-01 | As a user, I can pick a meal time (breakfast/lunch/dinner) to see relevant dishes. | P0 |
| US-02 | As a user, I can tap "Bahala na si Batman" for a random dish suggestion. | P1 |
| US-03 | As a user, I see a time-based greeting when I open the app. | P2 |

### Epic 2 — Fridge Inventory Search
| ID | Story | Priority |
|---|---|---|
| US-04 | As a user, I can list the ingredients currently in my fridge. | P0 |
| US-05 | As a user, I can see dishes I can cook with those ingredients. | P0 |
| US-06 | As a user, I can see which ingredients are missing to complete a recipe. | P1 |

### Epic 3 — AI Dish Suggestions
| ID | Story | Priority |
|---|---|---|
| US-07 | As a user, AI suggests dishes based on my ingredient combination. | P0 |
| US-08 | As a user, I see compatible dish variations (e.g., adobo, inasal). | P1 |
| US-09 | As a user, I can save a recipe to cook later. | P0 |

### Epic 4 — Community & Contribution
| ID | Story | Priority |
|---|---|---|
| US-10 | As a user, I can submit my own recipe via "ADD ULAM". | P1 |
| US-11 | As a user, I can rate and comment on recipes. | P1 |
| US-12 | As a contributor, my name appears on recipes I submit. | P2 |

### Epic 5 — Discovery & Planning
| ID | Story | Priority |
|---|---|---|
| US-13 | As a user, I can browse recipes by category, region, or ingredient. | P1 |
| US-14 | As a user, I can plan meals for the week. | P2 |
| US-15 | As a user, I can auto-generate a grocery list from my meal plan. | P2 |

---

## 4. Functional Requirements

### 4.1 Meal Decision Helper
- Four primary actions on home: Lunch, Breakfast, Dinner, Random.
- Random mode returns one dish with a single tap; reshuffles on repeat tap.
- Greeting derived from device local time (Morning / Afternoon / Evening).

### 4.2 Fridge Inventory
- Add ingredients manually via search-as-you-type against a canonical ingredient list.
- Ingredients stored per user and persisted across sessions.
- Each suggested dish shows `complete` or `kulang: <missing items>`.

### 4.3 AI Suggestions
- Input: fridge ingredients + meal time. Output: 3 ranked dishes with `has[]`, `missing[]`, and estimated time.
- Responses returned in structured JSON for deterministic UI rendering.
- "Report wrong dish" action on every suggestion feeds a review queue.

### 4.4 Contribution Flow
- Form: dish name, category, ingredient list, step-by-step instructions, optional photo.
- Submissions enter `pending` state; surfaced to users only after `approved`.

### 4.5 Planning
- Weekly grid (Mon–Sun) with one dish slot per meal type.
- Grocery list aggregates and de-duplicates ingredients across planned recipes.

---

## 5. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Performance | Recipe suggestions return in < 2s (p95). |
| Offline | Saved recipes viewable without connectivity. |
| Accessibility | Adjustable font size; voice input for ingredients; min 44pt tap targets. |
| Scalability | Support 100k+ concurrent active users. |
| Localization | All UI strings in Taglish; ingredient names stored in TL + EN. |
| Privacy | Guest mode (no account required); no sensitive data collection. |

---

## 6. Information Architecture

```
Home / Dashboard
├── Meal-time entry (Lunch / Breakfast / Dinner / Random)
├── Fridge Inventory
│   └── AI Suggestions → Recipe Detail
├── Discover (browse by category/region/ingredient)
├── Meal Planner → Grocery List
└── ADD ULAM (contribution form)
```

### Key Screens
1. **Home** — greeting, 2×2 meal buttons, fridge chips, compatible dishes, ADD ULAM CTA.
2. **Fridge** — ingredient chips with remove, add field, AI-suggest button, completeness indicators.
3. **Recipe Detail** — image, rating, time/difficulty, ingredient checklist, steps, cook/save actions.
4. **ADD ULAM** — name, category, ingredients, instructions, photo upload, submit.
5. **Meal Planner** — weekly grid, generate grocery list, copy/share.

---

## 7. Data Model

### 7.1 Entities

**users**
| Field | Type | Notes |
|---|---|---|
| user_id | UUID (PK) | |
| email | String | Unique, nullable for guests |
| display_name | String | Public name |
| photo_url | String | Optional |
| premium_status | Boolean | Free / Premium |
| created_at | Timestamp | |
| last_active | Timestamp | |

**ingredients**
| Field | Type | Notes |
|---|---|---|
| ingredient_id | UUID (PK) | |
| name | String | TL, e.g. "bawang" |
| name_en | String | EN, e.g. "garlic" |
| category | Enum | gulay, karne, pampalasa, … |

**user_fridge**
| Field | Type | Notes |
|---|---|---|
| user_id | UUID (FK) | → users |
| ingredient_id | UUID (FK) | → ingredients |
| added_at | Timestamp | |

**recipes**
| Field | Type | Notes |
|---|---|---|
| recipe_id | UUID (PK) | |
| title | String | |
| description | Text | |
| meal_type | Enum | breakfast, lunch, dinner, any |
| difficulty | Enum | easy, medium, hard |
| cooking_time_mins | Integer | |
| image_url | String | |
| contributor_id | UUID (FK) | → users |
| is_ai_generated | Boolean | |
| total_saves | Integer | |
| created_at | Timestamp | |

**recipe_ingredients**
| Field | Type | Notes |
|---|---|---|
| recipe_id | UUID (FK) | |
| ingredient_id | UUID (FK) | |
| quantity | String | e.g. "500g" |
| is_optional | Boolean | |

**recipe_instructions**
| Field | Type | Notes |
|---|---|---|
| recipe_id | UUID (FK) | |
| step_number | Integer | |
| instruction | Text | |

**saved_recipes**, **meal_plans**, **contributions**, **reviews** follow the same FK pattern (user_id, recipe_id + status/rating/timestamps).

### 7.2 Relationships
```
users ─┬─ user_fridge ── ingredients
       ├─ saved_recipes ─ recipes ─┬─ recipe_ingredients ─ ingredients
       ├─ meal_plans ──────────────┤
       ├─ contributions ───────────┴─ recipe_instructions
       └─ reviews ── recipes
```

---

## 8. API Surface (v1)

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Sign up |
| POST | `/api/auth/login` | Log in |
| GET | `/api/fridge/:userId` | Get fridge contents |
| POST | `/api/fridge/:userId` | Add ingredient |
| DELETE | `/api/fridge/:userId/:ingredientId` | Remove ingredient |
| GET | `/api/recipes/suggest` | AI suggestions (fridge + meal time) |
| GET | `/api/recipes/random` | Random dish |
| GET | `/api/recipes/:recipeId` | Single recipe |
| POST | `/api/recipes/contribute` | Submit recipe |
| GET | `/api/mealplan/:userId` | Weekly plan |
| POST | `/api/mealplan/:userId` | Save plan |
| GET | `/api/mealplan/:userId/grocery` | Generate grocery list |

### AI Suggestion Contract
```json
{
  "dishes": [
    {
      "name": "Chicken Adobo",
      "has": ["garlic", "chicken", "toyo", "sibuyas"],
      "missing": ["laurel", "paminta", "suka"],
      "time_mins": 45
    }
  ]
}
```

---

## 9. Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| Frontend | Flutter or React Native | Single codebase, native feel |
| Backend | Firebase / Supabase | Real-time, fast to scale |
| AI | LLM API + structured JSON output | Filipino-cuisine prompt tuning |
| Database | Firestore + PostgreSQL | Document store + relational queries |
| Cache | Redis | Sub-2s suggestion latency |
| Analytics | Firebase Analytics / Mixpanel | Funnel + retention tracking |

---

## 10. Monetization

| Tier | Offering |
|---|---|
| Free | Basic search, 5 saved recipes, limited AI suggestions |
| Premium (₱99/mo) | Unlimited AI, meal planner, grocery list, offline, ad-free |
| Tip | "Buy me a toyo, mantika, bawang" — voluntary support |

---

## 11. Success Metrics

| Metric | Target | Timeline |
|---|---|---|
| Daily Active Users | > 1,000 | 3 months |
| Recipes saved / session | > 3 | 3 months |
| AI suggestion helpfulness | > 85% | 3 months |
| Community contributions | > 500 | 6 months |
| App store rating | > 4.5★ | 6 months |
| Premium conversion | > 5% | 12 months |

---

## 12. Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Inaccurate AI suggestions | Med | High | "Report wrong dish" + manual review + feedback loop |
| Thin recipe DB at launch | High | Med | Seed 500+ recipes; partner with food blogs; contribution incentives |
| Hard to use for older users | Med | High | Large buttons, voice input, first-launch tutorial, persona testing |
| Slow suggestion load | Low | Med | Redis cache, lazy loading, offline saved recipes |
| Low community participation | Med | Med | Gamification: badges, "Contributor of the Week" |
| Privacy concerns | Low | High | Guest mode, no sensitive data, transparent policy |

---

## 13. Delivery Plan

| Phase | Duration | Deliverables |
|---|---|---|
| 1 — MVP | 8 wks | Home, fridge inventory, static suggestions, ADD ULAM form |
| 2 — AI | 6 wks | AI suggestions, compatible dishes, random mode |
| 3 — Community | 4 wks | Reviews, ratings, contributor profiles |
| 4 — Planning | 6 wks | Weekly planner, grocery list, save/cook later |
| 5 — Launch | 4 wks | Offline mode, perf tuning, store submission |

---

## 14. Open Questions
- Should guest-mode fridge data sync if the user later registers?
- What is the moderation SLA for community submissions?
- Region tagging — by Philippine region, or free-text?
- AI cost ceiling per user on the free tier?
