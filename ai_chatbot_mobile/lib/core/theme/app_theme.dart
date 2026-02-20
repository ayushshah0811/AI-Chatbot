import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern 2026 AI SaaS application theme.
///
/// Uses a hot-pink / magenta seed color with Material 3 tonal surfaces,
/// Inter typography, soft pink gradient backgrounds, and layered depth.
/// All colors derive from [ColorScheme] — no hardcoded values outside this file.
class AppTheme {
  AppTheme._();

  // ── Seed Color ──────────────────────────────────────────────────────────

  /// Primary seed: hot pink / magenta — vibrant and modern.
  static const Color _seedColor = Color(0xFFE91E63);

  /// Secondary seed: soft pink accent for secondary elements.
  static const Color _secondaryColor = Color(0xFFFF80AB);

  /// Tertiary seed: light purple for warm complementary highlights.
  static const Color _tertiaryColor = Color(0xFFCE93D8);

  // ── Typography ──────────────────────────────────────────────────────────

  /// Premium sans-serif font for the entire app.
  static TextTheme get _textTheme {
    return GoogleFonts.interTextTheme();
  }

  // ── Light Theme ─────────────────────────────────────────────────────────

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFFF8FA),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFFF5F7),
      surfaceContainer: const Color(0xFFF3EDF0),
      surfaceContainerHigh: const Color(0xFFEDE5E8),
      surfaceContainerHighest: const Color(0xFFE5DDE0),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.dark,
      // Layered soft dark — warm wine / magenta undertones.
      surface: const Color(0xFF2A1620),
      surfaceContainerLowest: const Color(0xFF221018),
      surfaceContainerLow: const Color(0xFF301B25),
      surfaceContainer: const Color(0xFF382130),
      surfaceContainerHigh: const Color(0xFF42283A),
      surfaceContainerHighest: const Color(0xFF4A3044),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ── Theme Builder ───────────────────────────────────────────────────────

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textTheme = _textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: brightness,
      // Transparent scaffold — the gradient background is painted by the screen.
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.comfortable,

      // ── AppBar ── transparent, centered title, 0 elevation.
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: isLight ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),

      // ── Input Fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.35),
        ),
      ),

      // ── Buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),

      // ── Popup Menu ──
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        color: isLight
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerHigh,
      ),

      // ── Dialogs ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        thickness: 0.5,
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),

      // ── Tooltip ──
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }

  // ── Gradient Background ─────────────────────────────────────────────────

  /// Soft vertical gradient background for the entire screen.
  /// Light mode: warm pink-white → soft pink.
  /// Dark mode: deep wine → warm dark magenta.
  static LinearGradient backgroundGradient(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isLight
          ? [const Color(0xFFFFF8FA), const Color(0xFFFBE4F0)]
          : [const Color(0xFF2A1620), const Color(0xFF351C2A)],
      stops: const [0.0, 1.0],
    );
  }

  // ── Chat-Specific Colors ────────────────────────────────────────────────

  /// User bubble: same as bot bubble — white in light, surfaceContainerHigh in dark.
  static Color userBubbleColor(BuildContext context) {
    return botBubbleColor(context);
  }

  /// Bot bubble: white in light mode, dark surface in dark mode.
  static Color botBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  /// Text color for user message bubbles — dark text on white/light bubble.
  static Color userBubbleTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Text color for bot message bubbles.
  static Color botBubbleTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Code block background — dark themed regardless of app brightness.
  static Color codeBlockColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF1E1E2E)
        : const Color(0xFF141425);
  }

  /// Code block text color.
  static Color codeBlockTextColor(BuildContext context) {
    return const Color(0xFFCDD6F4);
  }

  /// Accent gradient for premium elements (AI avatar, send button).
  static LinearGradient get accentGradient => const LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Circular icon container decoration for AppBar icons.
  static BoxDecoration iconContainerDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
      shape: BoxShape.circle,
    );
  }
}
