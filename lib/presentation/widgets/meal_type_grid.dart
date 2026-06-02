import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';

/// One tappable meal-type tile.
class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2x2 grid of meal-time entry points: Breakfast, Lunch, Dinner, Random.
class MealTypeGrid extends StatelessWidget {
  const MealTypeGrid({super.key, required this.onSelect, required this.onRandom});

  final void Function(MealType type) onSelect;
  final VoidCallback onRandom;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.4,
      children: [
        _MealTile(
          label: l.mealBreakfast,
          emoji: '🍳',
          color: AppColors.breakfast,
          onTap: () => onSelect(MealType.breakfast),
        ),
        _MealTile(
          label: l.mealLunch,
          emoji: '🍛',
          color: AppColors.lunch,
          onTap: () => onSelect(MealType.lunch),
        ),
        _MealTile(
          label: l.mealDinner,
          emoji: '🍲',
          color: AppColors.dinner,
          onTap: () => onSelect(MealType.dinner),
        ),
        _MealTile(
          label: l.randomTile,
          emoji: '🎲',
          color: AppColors.random,
          onTap: onRandom,
        ),
      ],
    );
  }
}
