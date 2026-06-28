import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_storage.dart';
import 'data/local/recipe_loader.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/recipe_provider.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sprint 6: register the on-device LLM engine for .litertlm Gemma models.
  // The HF token (free, for the one-time gated download) comes from
  // --dart-define=HUGGINGFACE_TOKEN=hf_xxx; empty is fine until the user opts
  // into downloading the model.
  const hfToken = String.fromEnvironment('HUGGINGFACE_TOKEN');
  FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine()],
    huggingFaceToken: hfToken.isNotEmpty ? hfToken : null,
  );

  await initLocalStorage();
  final recipes = await loadSeedRecipes();
  runApp(
    ProviderScope(
      overrides: [seedRecipesProvider.overrideWithValue(recipes)],
      child: const AnongUlamApp(),
    ),
  );
}

class AnongUlamApp extends ConsumerWidget {
  const AnongUlamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Anong Ulam Today?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
