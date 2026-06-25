import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value == true;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600);
              }
              return const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500);
            }),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (int index) => _onItemTapped(index, context, isAuthenticated),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, color: AppColors.textMuted),
                selectedIcon: _buildSelectedIcon(Icons.home),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bookmark_border, color: AppColors.textMuted),
                selectedIcon: _buildSelectedIcon(Icons.bookmark),
                label: 'Favoriler',
              ),
              NavigationDestination(
                icon: Icon(isAuthenticated ? Icons.person_outline : Icons.login, color: AppColors.textMuted),
                selectedIcon: _buildSelectedIcon(isAuthenticated ? Icons.person : Icons.login),
                label: isAuthenticated ? 'Profil' : 'Giriş',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedIcon(IconData iconData) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: Colors.black, size: 20),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/favorites')) {
      return 1;
    }
    if (location.startsWith('/profile') || location.startsWith('/login')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isAuthenticated) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        if (isAuthenticated) {
          context.go('/profile');
        } else {
          context.go('/login');
        }
        break;
    }
  }
}
