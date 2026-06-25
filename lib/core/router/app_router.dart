import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/navigation/scaffold_with_navbar.dart';
import '../../features/news/screens/home_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey, // Covers bottom nav
        path: '/news/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return NewsDetailScreen(slug: slug);
        },
      ),
    ],
  );
});
