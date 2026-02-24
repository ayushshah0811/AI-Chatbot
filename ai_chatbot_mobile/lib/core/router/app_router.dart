import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

/// Application route paths.
class AppRoutes {
  AppRoutes._();

  /// Login screen path (initial route).
  static const String login = '/';

  /// Chat screen path.
  static const String chat = '/chat';

  /// Named route identifiers.
  static const String loginName = 'login';
  static const String chatName = 'chat';
}

/// GoRouter configuration for the application.
///
/// Login screen is the initial route. After successful authentication
/// the user is navigated to the chat screen.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      name: AppRoutes.chatName,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  ),
);
