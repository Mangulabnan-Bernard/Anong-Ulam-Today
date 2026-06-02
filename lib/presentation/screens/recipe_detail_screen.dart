import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe_match.dart';
import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    final saved = ref.watch(savedRecipesProvider);
    final recipe = recipes.where((r) => r.id == recipeId).firstOrNull;

    if (recipe == null) {
      return Scaffold(
        body: Center(child: Text('${context.l10n.recipeNotFound} 😢')),
      );
    }

    final theme = Theme.of(context);
    final isSaved = saved.contains(recipe.id);
    final l = context.l10n;
    final fridge = ref.watch(fridgeProvider);
    final fridgeNames = fridge.map((i) => i.name.toLowerCase()).toSet();
    final match = fridge.isEmpty ? null : matchRecipe(recipe, fridgeNames);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                color: Colors.white,
                onPressed: () =>
                    ref.read(savedRecipesProvider.notifier).toggle(recipe.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primaryDark],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 80)),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(recipe.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoPill(
                        icon: Icons.star,
                        label: recipe.rating.toStringAsFixed(1),
                        color: AppColors.accent),
                    const SizedBox(width: 10),
                    _InfoPill(
                        icon: Icons.schedule,
                        label: '${recipe.cookingTimeMins} min',
                        color: AppColors.secondary),
                    const SizedBox(width: 10),
                    _InfoPill(
                        icon: Icons.bar_chart,
                        label: recipe.difficulty.localized(l),
                        color: AppColors.dinner),
                  ],
                ),
                const SizedBox(height: 24),
                if (match == null) ...[
                  // No fridge yet — plain ingredient list.
                  Text(l.ingredients,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map(
                    (ing) => _IngredientRow(
                      name:
                          '${ing.name}${ing.isOptional ? ' (${l.optional})' : ''}',
                      quantity: ing.quantity,
                    ),
                  ),
                ] else ...[
                  _MatchSummary(match: match),
                  const SizedBox(height: 20),
                  // GROUP 1: already in fridge
                  if (match.have.isNotEmpty) ...[
                    _GroupHeader(
                        icon: Icons.check_circle,
                        color: AppColors.success,
                        label: '${l.inYourFridge} (${match.have.length})'),
                    const SizedBox(height: 8),
                    ...match.have.map(
                      (ing) => _IngredientRow(
                        name:
                            '${ing.name}${ing.isOptional ? ' (${l.optional})' : ''}',
                        quantity: ing.quantity,
                        leadingIcon: Icons.check,
                        leadingColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // GROUP 2: need to buy (tappable → "I have this too")
                  if (match.missing.isNotEmpty) ...[
                    _GroupHeader(
                        icon: Icons.shopping_basket,
                        color: AppColors.warning,
                        label: '${l.needToBuy} (${match.missing.length})'),
                    const SizedBox(height: 2),
                    Text(l.tapMissingHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55))),
                    const SizedBox(height: 8),
                    ...match.missing.map(
                      (ing) => _IngredientRow(
                        name:
                            '${ing.name}${ing.isOptional ? ' (${l.optional})' : ''}',
                        quantity: ing.quantity,
                        leadingIcon: Icons.add_shopping_cart,
                        leadingColor: AppColors.warning,
                        onTap: () {
                          final added = ref
                              .read(fridgeProvider.notifier)
                              .addByName(ing.name);
                          if (added != null) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  content: Text(l.markedHave(ing.name))));
                          }
                        },
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        const Icon(Icons.celebration,
                            color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(l.allSetToCook,
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                ],
                const SizedBox(height: 24),
                Text(l.instructions,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...recipe.instructions.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary,
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(e.value,
                                  style: theme.textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                // Copy shopping list — only when there's something to buy.
                if (match != null && match.missing.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      final items = match.missing
                          .map((i) => '• ${i.name} (${i.quantity})')
                          .join('\n');
                      final text =
                          '${l.shoppingListTitle(recipe.title)}\n$items';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.listCopied)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.copy_all),
                    label: Text(l.copyList),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l.cookSnack} 🍽️')),
                      );
                    },
                    icon: const Icon(Icons.restaurant),
                    label: Text(l.cookNow),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner summarizing fridge match: "Complete!" or "Missing: x, y".
class _MatchSummary extends StatelessWidget {
  const _MatchSummary({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final complete = match.isComplete;
    final color = complete ? AppColors.success : AppColors.warning;
    final missingNames = match.missing
        .where((i) => !i.isOptional)
        .map((i) => i.name)
        .join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(complete ? Icons.check_circle : Icons.shopping_basket,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete ? l.canCook : l.youAreMissing,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                if (!complete) ...[
                  const SizedBox(height: 2),
                  Text(missingNames,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for an ingredient group (have / need to buy).
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(
      {required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

/// A single ingredient line. Tappable when [onTap] is provided (e.g. "I have
/// this too" for a missing item).
class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.quantity,
    this.leadingIcon,
    this.leadingColor,
    this.onTap,
  });

  final String name;
  final String quantity;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(leadingIcon ?? Icons.fiber_manual_record,
              size: leadingIcon == null ? 10 : 20,
              color: leadingColor ?? AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
          Text(quantity,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.add_circle_outline,
                size: 18,
                color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: row,
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
