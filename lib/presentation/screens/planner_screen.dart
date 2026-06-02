import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  List<String> _days(AppLocalizations l) => [
        l.dayMon, l.dayTue, l.dayWed, l.dayThu, l.dayFri, l.daySat, l.daySun,
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;
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
                  child: Text(
                    l.plannerHint,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._days(l).map(
            (day) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(day[0],
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(day,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l.plannerNoMeal),
                trailing: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.plannerAddMeal(day))),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
