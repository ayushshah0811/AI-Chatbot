import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Application entry point.
///
/// Wraps the app in a [ProviderScope] for Riverpod state management,
/// configures theming via [AppTheme], and sets up GoRouter navigation.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AiChatbotApp()));
}

/// Root application widget.
class AiChatbotApp extends StatelessWidget {
  const AiChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Routing
      routerConfig: appRouter,
    );
  }
}
