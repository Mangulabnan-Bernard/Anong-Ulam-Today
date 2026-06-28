import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';
import '../../l10n/app_localizations.dart';
import '../providers/planner_provider.dart';
import '../providers/recipe_provider.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  List<String> _dayLabels(AppLocalizations l) => [
        l.dayMon, l.dayTue, l.dayWed, l.dayThu, l.dayFri, l.daySat, l.daySun,
      ];

  void _openPicker(
    BuildContext context,
    WidgetRef ref, {
    required String dayKey,
    required String dayLabel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DishPickerSheet(dayKey: dayKey, dayLabel: dayLabel),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final plan = ref.watch(plannerProvider);
    final recipes = ref.watch(recipesProvider);
    final byId = {for (final r in recipes) r.id: r};
    final labels = _dayLabels(l);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.plannerHint, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < plannerDayKeys.length; i++)
            _DayCard(
              dayKey: plannerDayKeys[i],
              dayLabel: labels[i],
              recipe: byId[plan[plannerDayKeys[i]]],
              onAdd: () => _openPicker(
                context,
                ref,
                dayKey: plannerDayKeys[i],
                dayLabel: labels[i],
              ),
              onRemove: () =>
                  ref.read(plannerProvider.notifier).removeMeal(plannerDayKeys[i]),
              onOpenRecipe: (id) => context.push('/recipe/$id'),
            ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayKey,
    required this.dayLabel,
    required this.recipe,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenRecipe,
  });

  final String dayKey;
  final String dayLabel;
  final Recipe? recipe;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<String> onOpenRecipe;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasMeal = recipe != null;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: hasMeal
              ? Text(recipe!.emoji, style: const TextStyle(fontSize: 18))
              : Text(
                  dayLabel[0],
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
        ),
        title: Text(dayLabel,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(hasMeal ? recipe!.title : l.plannerNoMeal),
        trailing: hasMeal
            ? IconButton(
                tooltip: l.plannerRemoveMeal,
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: onRemove,
              )
            : const Icon(Icons.add_circle_outline, color: AppColors.primary),
        onTap: hasMeal ? () => onOpenRecipe(recipe!.id) : onAdd,
      ),
    );
  }
}

/// Searchable dish picker used to assign a recipe to a given day.
class _DishPickerSheet extends ConsumerStatefulWidget {
  const _DishPickerSheet({required this.dayKey, required this.dayLabel});

  final String dayKey;
  final String dayLabel;

  @override
  ConsumerState<_DishPickerSheet> createState() => _DishPickerSheetState();
}

class _DishPickerSheetState extends ConsumerState<_DishPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = _query.toLowerCase().trim();
    final recipes = ref.watch(recipesProvider).where((r) {
      if (query.isEmpty) return true;
      return r.title.toLowerCase().contains(query);
    }).toList();

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
          Text(
            l.plannerChooseDish(widget.dayLabel),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: l.plannerSearchDish,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, i) {
                final r = recipes[i];
                return ListTile(
                  leading: Text(r.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(r.title),
                  subtitle: Text('${r.cookingTimeMins} min'),
                  onTap: () {
                    ref
                        .read(plannerProvider.notifier)
                        .setMeal(widget.dayKey, r.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
