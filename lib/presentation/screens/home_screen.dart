import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../providers/recipe_provider.dart';
import '../widgets/meal_type_grid.dart';
import '../widgets/recipe_card.dart';
import '../widgets/time_greeting.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showRandom(BuildContext context, WidgetRef ref) {
    final recipes = ref.read(recipesProvider);
    final pick = recipes[Random(DateTime.now().millisecondsSinceEpoch).nextInt(recipes.length)];
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎲 ${l.randomSheetTitle}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(pick.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(pick.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(pick.description, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/recipe/${pick.id}');
              },
              icon: const Icon(Icons.restaurant_menu),
              label: Text(l.viewRecipe),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    final saved = ref.watch(savedRecipesProvider);
    final l = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const TimeGreeting(),
            const SizedBox(height: 24),
            MealTypeGrid(
              onSelect: (type) {
                ref.read(recipeMealFilterProvider.notifier).update(type);
                context.go('/discover');
              },
              onRandom: () => _showRandom(context, ref),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/vote'),
                icon: const Text('🗳️', style: TextStyle(fontSize: 18)),
                label: Text(l.familyVoteCta),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.suggestedDishes,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                TextButton(
                  onPressed: () => context.go('/discover'),
                  child: Text(l.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recipes.take(4).map(
                  (r) => RecipeCard(
                    recipe: r,
                    isSaved: saved.contains(r.id),
                    onToggleSave: () =>
                        ref.read(savedRecipesProvider.notifier).toggle(r.id),
                    onTap: () => context.push('/recipe/${r.id}'),
                  ),
                ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/add'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add),
              label: Text(l.addUlamCta),
            ),
          ],
        ),
      ),
    );
  }
}
