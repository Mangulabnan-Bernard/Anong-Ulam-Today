import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_ingredients.dart';
import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class FridgeScreen extends ConsumerWidget {
  const FridgeScreen({super.key});

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddIngredientSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridge = ref.watch(fridgeProvider);
    final theme = Theme.of(context);
    final l = context.l10n;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l.add),
      ),
      body: fridge.isEmpty
          ? _EmptyFridge(onAdd: () => _openAddSheet(context, ref))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l.fridgeCount(fridge.length),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: fridge
                      .map(
                        (ing) => Chip(
                          avatar: Text(ing.emoji),
                          label: Text(ing.name),
                          onDeleted: () {
                            ref.read(fridgeProvider.notifier).remove(ing);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(l.swipeToDelete(ing.name)),
                                  action: SnackBarAction(
                                    label: l.undo,
                                    onPressed: () => ref
                                        .read(fridgeProvider.notifier)
                                        .add(ing),
                                  ),
                                ),
                              );
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                _CookableSection(),
              ],
            ),
    );
  }
}

/// Shows recipes the user can cook now (best matches first) based on fridge.
class _CookableSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cookable = ref.watch(cookableRecipesProvider);
    // Fallback: if nothing fully cookable, show top-3 closest matches.
    final matches = ref.watch(matchedRecipesProvider);
    final showList =
        cookable.isNotEmpty ? cookable : matches.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.lunch),
            const SizedBox(width: 6),
            Text(l.cookableNow,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...showList.map(
          (m) => RecipeCard(
            recipe: m.recipe,
            match: m,
            onTap: () => context.push('/recipe/${m.recipe.id}'),
          ),
        ),
      ],
    );
  }
}

class _EmptyFridge extends StatelessWidget {
  const _EmptyFridge({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧊', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(l.fridgeEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l.fridgeEmptyBody,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l.addIngredient),
          ),
        ],
      ),
    );
  }
}

class _AddIngredientSheet extends ConsumerStatefulWidget {
  const _AddIngredientSheet();

  @override
  ConsumerState<_AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends ConsumerState<_AddIngredientSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final fridge = ref.watch(fridgeProvider);
    final results = kCommonIngredients
        .where((i) =>
            i.name.toLowerCase().contains(_query.toLowerCase()) ||
            i.nameEn.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.l10n.searchIngredientHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: results.map((ing) {
                final added = fridge.any((f) => f.id == ing.id);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final notifier = ref.read(fridgeProvider.notifier);
                    added ? notifier.remove(ing) : notifier.add(ing);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: added
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: added
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(ing.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(ing.name,
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}
