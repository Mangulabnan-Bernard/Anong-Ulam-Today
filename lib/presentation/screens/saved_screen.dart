import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedRecipesProvider);
    final recipes = ref.watch(recipesProvider);
    final savedRecipes =
        recipes.where((r) => saved.contains(r.id)).toList();
    final l = context.l10n;

    if (savedRecipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.savedTitle,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💔', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(l.savedEmptyTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  l.savedEmptyBody,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.savedTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: savedRecipes
              .map((r) => RecipeCard(
                    recipe: r,
                    isSaved: true,
                    onToggleSave: () =>
                        ref.read(savedRecipesProvider.notifier).toggle(r.id),
                    onTap: () => context.push('/recipe/${r.id}'),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
