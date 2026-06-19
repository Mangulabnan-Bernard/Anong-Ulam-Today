import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';
import '../../domain/ai/dish_suggestion.dart';
import '../providers/ai_suggestion_provider.dart';
import '../providers/fridge_provider.dart';
import '../widgets/recipe_card.dart';

/// AI Suggestions (Sprint 5): ranked dishes from the user's fridge + a chosen
/// meal time. Powered by the offline [LocalSuggestionService]; the UI is
/// LLM-ready (async, loading/error states).
class AiSuggestScreen extends ConsumerStatefulWidget {
  const AiSuggestScreen({super.key});

  @override
  ConsumerState<AiSuggestScreen> createState() => _AiSuggestScreenState();
}

class _AiSuggestScreenState extends ConsumerState<AiSuggestScreen> {
  /// null == any meal.
  MealType? _meal;

  static const _mealChoices = <MealType?>[
    null,
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fridge = ref.watch(fridgeProvider);
    final async = ref.watch(aiSuggestionsProvider(_meal));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨ '),
            Text(l.aiSuggestTitle),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.aiRefresh,
            onPressed: () =>
                ref.invalidate(aiSuggestionsProvider(_meal)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: fridge.isEmpty
          ? const _EmptyFridge()
          : Column(
              children: [
                const _SmartAiBanner(),
                _MealSelector(
                  meals: _mealChoices,
                  selected: _meal,
                  onSelect: (m) => setState(() => _meal = m),
                ),
                Expanded(
                  child: async.when(
                    loading: () => const _Thinking(),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (suggestions) => suggestions.isEmpty
                        ? const _NoMatches()
                        : _SuggestionList(suggestions: suggestions),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Opt-in banner for the on-device Gemma (Smart AI) engine: triggers the
/// one-time ~550 MB model download with progress, then a toggle to turn it
/// on/off. Until enabled, the screen uses the offline heuristic.
class _SmartAiBanner extends ConsumerWidget {
  const _SmartAiBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final download = ref.watch(gemmaDownloadProvider);
    final on = ref.watch(useRagEngineProvider);
    final notifier = ref.read(gemmaDownloadProvider.notifier);

    Widget body;
    switch (download.phase) {
      case GemmaPhase.downloading:
        body = _BannerProgress(
          label: 'Kinukuha ang AI model… ${download.percent}%',
          value: download.percent / 100,
        );
      case GemmaPhase.loading:
        body = const _BannerProgress(
          label: 'Inihahanda ang AI…',
          value: null,
        );
      case GemmaPhase.error:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Hindi na-load ang AI model.'),
                ),
                TextButton(
                  onPressed: notifier.enable,
                  child: const Text('Ulitin'),
                ),
              ],
            ),
            if (download.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  download.error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.warning),
                ),
              ),
          ],
        );
      case GemmaPhase.ready:
      case GemmaPhase.idle:
        body = Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Smart AI (Gemma)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    on
                        ? 'Tumatakbo sa device — offline, libre'
                        : 'Mas matalinong ranking · ~550MB isang beses',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: on,
              onChanged: (want) =>
                  want ? notifier.enable() : notifier.disable(),
            ),
          ],
        );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: body,
    );
  }
}

class _BannerProgress extends StatelessWidget {
  const _BannerProgress({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: value, minHeight: 6),
        ),
      ],
    );
  }
}

class _MealSelector extends StatelessWidget {
  const _MealSelector({
    required this.meals,
    required this.selected,
    required this.onSelect,
  });

  final List<MealType?> meals;
  final MealType? selected;
  final ValueChanged<MealType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text('${l.aiForMeal}:',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: meals.map((m) {
                  final label = m?.localized(l) ?? l.mealAny;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected == m,
                      onSelected: (_) => onSelect(m),
                      selectedColor: AppColors.primary.withValues(alpha: 0.20),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(l.aiThinking,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.suggestions});

  final List<DishSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: suggestions.length + 1,
      itemBuilder: (context, i) {
        if (i == suggestions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.offline_bolt,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(l.aiOfflineNote,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }
        return _SuggestionCard(suggestion: suggestions[i], rank: i + 1);
      },
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.suggestion, required this.rank});

  final DishSuggestion suggestion;
  final int rank;

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    await reportWrongDish(suggestion.recipe.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.l10n.aiReportThanks),
        duration: const Duration(seconds: 3),
      ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isTop = rank == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8, bottom: 2),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isTop
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isTop ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isTop)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('⭐ ${l.aiTopPick}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              _ConfidenceChip(percent: suggestion.confidencePercent),
            ],
          ),
        ),
        RecipeCard(
          recipe: suggestion.recipe,
          match: suggestion.match,
          onTap: () => context.push('/recipe/${suggestion.recipe.id}'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.kitchen,
                  size: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 4),
              Text(
                l.aiMatchRatio(
                    suggestion.haveRequired, suggestion.requiredTotal),
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _report(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.flag_outlined, size: 15),
                label: Text(l.aiReportWrong,
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80
        ? AppColors.success
        : percent >= 50
            ? AppColors.warning
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.l10n.aiConfidence(percent),
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤔', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(l.aiNoMatches,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _EmptyFridge extends StatelessWidget {
  const _EmptyFridge();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(l.aiNeedIngredients,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/fridge'),
              icon: const Icon(Icons.kitchen),
              label: Text(l.navFridge),
            ),
          ],
        ),
      ),
    );
  }
}
