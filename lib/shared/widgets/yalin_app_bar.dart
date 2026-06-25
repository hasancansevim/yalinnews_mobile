import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

class YalinAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const YalinAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value == true;

    return AppBar(
      centerTitle: false,
      title: const Text(
        'YALIN',
        style: TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          tooltip: 'Temayı Değiştir',
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            context.push('/favorites');
          },
          tooltip: 'Favoriler',
        ),
        if (isAuthenticated) ...[
          TextButton(
            onPressed: () {
              context.push('/profile');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD4AF37),
              side: const BorderSide(color: Color(0xFFD4AF37)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Profil'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Çıkış Yap'),
          ),
          const SizedBox(width: 16),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton(
              onPressed: () {
                context.push('/login');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37)),
                foregroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Giriş Yap'),
            ),
          ),
        ]
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
