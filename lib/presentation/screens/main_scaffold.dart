import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../providers/locale_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/theme_provider.dart';
import 'add_ulam_screen.dart';
import 'discover_screen.dart';
import 'fridge_screen.dart';
import 'home_screen.dart';
import 'planner_screen.dart';

/// Root scaffold that hosts the 5 main tabs via a bottom navigation bar.
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  late int _index = widget.initialIndex;

  static const _tabs = [
    HomeScreen(),
    FridgeScreen(),
    DiscoverScreen(),
    PlannerScreen(),
    AddUlamScreen(),
  ];

  void _openSettings() {
    final l = context.l10n;
    final locale = ref.read(localeProvider);
    final themeMode = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.settings,
                  style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 16),
              // Language
              Text(l.language,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'tl', label: Text(l.tagalog)),
                  ButtonSegment(value: 'en', label: Text(l.english)),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (s) {
                  ref.read(localeProvider.notifier).set(Locale(s.first));
                  Navigator.pop(sheetCtx);
                },
              ),
              const SizedBox(height: 20),
              // Theme
              Text(l.theme,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.light, label: Text(l.themeLight)),
                  ButtonSegment(
                      value: ThemeMode.dark, label: Text(l.themeDark)),
                  ButtonSegment(
                      value: ThemeMode.system, label: Text(l.themeSystem)),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [
      l.appTitle,
      l.fridgeTitle,
      l.discoverTitle,
      l.plannerTitle,
      l.addUlamTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          _SavedButton(count: ref.watch(savedRecipesProvider).length),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.tune),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.4),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l.navHome),
          NavigationDestination(
              icon: const Icon(Icons.kitchen_outlined),
              selectedIcon: const Icon(Icons.kitchen),
              label: l.navFridge),
          NavigationDestination(
              icon: const Icon(Icons.search),
              selectedIcon: const Icon(Icons.manage_search),
              label: l.navDiscover),
          NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today),
              label: l.navPlanner),
          NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: const Icon(Icons.add_circle),
              label: l.navAddUlam),
        ],
      ),
    );
  }
}

/// AppBar heart button with a saved-count badge; opens the Saved screen.
class _SavedButton extends StatelessWidget {
  const _SavedButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.savedTitle,
      onPressed: () => context.push('/saved'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.favorite_border),
      ),
    );
  }
}
