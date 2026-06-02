import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';

/// Time-based greeting shown at the top of the Home screen.
class TimeGreeting extends StatelessWidget {
  const TimeGreeting({super.key, this.userName});

  final String? userName;

  ({String greeting, String subtext, String emoji}) _forHour(
      int hour, BuildContext context) {
    final l = context.l10n;
    if (hour < 12) {
      return (greeting: l.greetingMorning, subtext: l.greetingSubMorning, emoji: '🌅');
    }
    if (hour < 18) {
      return (greeting: l.greetingAfternoon, subtext: l.greetingSubAfternoon, emoji: '☀️');
    }
    return (greeting: l.greetingEvening, subtext: l.greetingSubEvening, emoji: '🌙');
  }

  @override
  Widget build(BuildContext context) {
    final info = _forHour(DateTime.now().hour, context);
    final theme = Theme.of(context);
    final name = (userName == null || userName!.isEmpty) ? '' : ', $userName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(info.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${info.greeting}$name',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          info.subtext,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
