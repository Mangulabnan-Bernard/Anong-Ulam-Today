import 'package:go_router/go_router.dart';

import '../../presentation/screens/ai_suggest_screen.dart';
import '../../presentation/screens/family_vote_screen.dart';
import '../../presentation/screens/main_scaffold.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/recipe_detail_screen.dart';
import '../../presentation/screens/saved_screen.dart';
import '../../presentation/screens/splash_screen.dart';

/// App-wide route configuration (GoRouter).
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(
        path: '/home',
        builder: (context, state) => const MainScaffold(initialIndex: 0)),
    GoRoute(
        path: '/fridge',
        builder: (context, state) => const MainScaffold(initialIndex: 1)),
    GoRoute(
        path: '/discover',
        builder: (context, state) => const MainScaffold(initialIndex: 2)),
    GoRoute(
        path: '/planner',
        builder: (context, state) => const MainScaffold(initialIndex: 3)),
    GoRoute(
        path: '/add',
        builder: (context, state) => const MainScaffold(initialIndex: 4)),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) =>
          RecipeDetailScreen(recipeId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
    GoRoute(
        path: '/suggest',
        builder: (context, state) => const AiSuggestScreen()),
    GoRoute(
        path: '/vote',
        builder: (context, state) => const FamilyVoteScreen()),
  ],
);
