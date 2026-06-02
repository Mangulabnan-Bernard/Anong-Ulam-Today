import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_match.dart';

/// Horizontal recipe card used in lists.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isSaved = false,
    this.onToggleSave,
    this.match,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  /// Optional fridge-match info; when provided, shows have/missing badge.
  final RecipeMatch? match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text(recipe.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 2),
                        Text('${recipe.cookingTimeMins} min',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.difficulty.localized(context.l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (match != null) ...[
                      const SizedBox(height: 6),
                      _MatchBadge(match: match!),
                    ],
                  ],
                ),
              ),
              if (onToggleSave != null)
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? AppColors.error : null,
                  ),
                  onPressed: onToggleSave,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill showing "Complete" or "Missing N" based on fridge match.
class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final complete = match.isComplete;
    final color = complete ? AppColors.success : AppColors.warning;
    final label = complete
        ? l.haveAllIngredients
        : l.missingCount(match.missingRequiredCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(complete ? Icons.check_circle : Icons.shopping_basket,
              size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
