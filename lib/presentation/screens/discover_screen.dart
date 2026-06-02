import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../data/models/recipe.dart';
import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(filteredRecipesProvider);
    final saved = ref.watch(savedRecipesProvider);
    final activeMeal = ref.watch(recipeMealFilterProvider);
    final fridge = ref.watch(fridgeProvider);
    final fridgeNames = fridge.map((i) => i.name.toLowerCase()).toSet();
    final l = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l.searchRecipeHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(recipeSearchQueryProvider.notifier).update(v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: l.filterAll,
                  selected: activeMeal == null,
                  onTap: () =>
                      ref.read(recipeMealFilterProvider.notifier).update(null),
                ),
                ...MealType.values.where((m) => m != MealType.any).map(
                      (m) => _FilterChip(
                        label: m.localized(l),
                        selected: activeMeal == m,
                        onTap: () => ref
                            .read(recipeMealFilterProvider.notifier)
                            .update(m),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(l.noRecipesFound,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: recipes
                        .map((r) => RecipeCard(
                              recipe: r,
                              isSaved: saved.contains(r.id),
                              match: fridge.isEmpty
                                  ? null
                                  : matchRecipe(r, fridgeNames),
                              onToggleSave: () => ref
                                  .read(savedRecipesProvider.notifier)
                                  .toggle(r.id),
                              onTap: () => context.push('/recipe/${r.id}'),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
