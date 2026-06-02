import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's active locale. Defaults to English; users can switch to
/// Tagalog in Settings. In-memory for now — persistence (Hive/prefs) comes
/// in a later sprint.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void set(Locale locale) => state = locale;

  void toggle() {
    state = state.languageCode == 'tl'
        ? const Locale('en')
        : const Locale('tl');
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
