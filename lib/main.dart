import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Assuming options will be added by the user later via flutterfire configure)
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization failed (probably config missing): $e');
  // }

  runApp(const ProviderScope(child: YalinNewsApp()));
}

class YalinNewsApp extends ConsumerWidget {
  const YalinNewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'YalınNews',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
