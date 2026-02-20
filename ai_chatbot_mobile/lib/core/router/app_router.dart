import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/screens/chat_screen.dart';

/// Application route paths.
class AppRoutes {
  AppRoutes._();

  /// Home / Chat screen path.
  static const String chat = '/';

  /// Named route identifiers.
  static const String chatName = 'chat';
}

/// GoRouter configuration for the application.
///
/// Currently a single-screen app with the chat screen as the home route.
/// Designed to be extended with additional routes as needed.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.chat,
  debugLogDiagnostics: true,
  routes: [
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
