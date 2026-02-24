import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/providers/session_provider.dart';

/// Hardcoded credentials mapped to user IDs.
const List<Map<String, String>> _validCredentials = [
  {'email': 'admin1@example.com', 'password': 'Admin@123', 'userId': '1'},
  {'email': 'admin2@example.com', 'password': 'Secure@456', 'userId': '2'},
  {'email': 'admin3@example.com', 'password': 'Test@789', 'userId': '3'},
];

/// Login screen shown on app launch.
///
/// Validates email/password against hardcoded credentials and navigates
/// to the chat screen on success.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate brief network delay for UX
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final match = _validCredentials.cast<Map<String, String>?>().firstWhere(
      (cred) => cred!['email'] == email && cred['password'] == password,
      orElse: () => null,
    );

    if (!mounted) return;

    if (match != null) {
      // Save the matched userId to session before navigating
      await ref.read(sessionProvider.notifier).setUserId(match['userId']!);
      // Invalidate chatProvider so it fully rebuilds with the new user's
      // session — this ensures the previous user's messages are not shown.
      ref.invalidate(chatProvider);
      if (!mounted) return;
      context.go(AppRoutes.chat);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo with gradient ring ──
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.3),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Image.jpg',
                          width: 91,
                          height: 91,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: DesignTokens.spacing.lg),

                    // ── Title ──
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: DesignTokens.spacing.xs),

                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),

                    SizedBox(height: DesignTokens.spacing.xxl),

                    // ── Email field ──
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: DesignTokens.borderRadius.lg,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: DesignTokens.spacing.md),

                    // ── Password field ──
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: DesignTokens.borderRadius.lg,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: DesignTokens.spacing.sm),

                    // ── Error message ──
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: DesignTokens.spacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: cs.error,
                            ),
                            SizedBox(width: DesignTokens.spacing.xxs),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.error,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: DesignTokens.spacing.md),

                    // ── Login button with gradient ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: _isLoading ? null : AppTheme.accentGradient,
                          color: _isLoading ? cs.surfaceContainerHigh : null,
                          borderRadius: DesignTokens.borderRadius.lg,
                          boxShadow: _isLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: DesignTokens.borderRadius.lg,
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
