import 'package:flutter/material.dart';

/// Modern 2026 AI assistant theme — vibrant indigo-teal palette.
///
/// Uses a deep indigo primary with electric teal accents, Inter typography,
/// smooth gradient backgrounds, and layered glassmorphism-inspired depth.
/// All fonts are bundled as assets — no runtime downloads required.
/// Optimized for readability with high-contrast text and vibrant accents.
class AppTheme {
  AppTheme._();

  // ── Seed Colors ─────────────────────────────────────────────────────────

  /// Primary seed: deep indigo — confident and modern.
  static const Color _seedColor = Color(0xFF6366F1);

  /// Secondary seed: electric teal — fresh, energetic accent.
  static const Color _secondaryColor = Color(0xFF14B8A6);

  /// Tertiary seed: soft violet — warm complementary highlight.
  static const Color _tertiaryColor = Color(0xFFA78BFA);

  // ── Typography ──────────────────────────────────────────────────────────

  /// Premium sans-serif font with bundled Noto Sans fallback.
  ///
  /// Inter (primary) + NotoSans + NotoSansSymbols2 are all bundled as
  /// Flutter font assets in pubspec.yaml — no runtime google_fonts
  /// downloads, so CanvasKit has all glyph data from first frame.
  static const _fontFamily = 'Inter';
  static const _fallbackFonts = ['NotoSans', 'NotoSansSymbols2', 'sans-serif'];

  static TextTheme get _textTheme {
    // Build TextTheme from the bundled Inter font with Noto fallbacks.
    const baseStyle = TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallbackFonts,
    );
    return const TextTheme(
      displayLarge: baseStyle,
      displayMedium: baseStyle,
      displaySmall: baseStyle,
      headlineLarge: baseStyle,
      headlineMedium: baseStyle,
      headlineSmall: baseStyle,
      titleLarge: baseStyle,
      titleMedium: baseStyle,
      titleSmall: baseStyle,
      bodyLarge: baseStyle,
      bodyMedium: baseStyle,
      bodySmall: baseStyle,
      labelLarge: baseStyle,
      labelMedium: baseStyle,
      labelSmall: baseStyle,
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────────

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FC),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF3F4F8),
      surfaceContainer: const Color(0xFFECEDF4),
      surfaceContainerHigh: const Color(0xFFE4E5EE),
      surfaceContainerHighest: const Color(0xFFDCDDE8),
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
      surface: const Color(0xFF0F1117),
      surfaceContainerLowest: const Color(0xFF0A0B10),
      surfaceContainerLow: const Color(0xFF151720),
      surfaceContainer: const Color(0xFF1A1C28),
      surfaceContainerHigh: const Color(0xFF222432),
      surfaceContainerHighest: const Color(0xFF2A2D3D),
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
      scaffoldBackgroundColor: Colors.transparent,
      visualDensity: VisualDensity.comfortable,

      // ── AppBar ── transparent, frosted glass feel.
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
          letterSpacing: -0.3,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: isLight ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.15),
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
            color: colorScheme.primary.withValues(alpha: 0.5),
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
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        color: isLight
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerHigh,
      ),

      // ── Dialogs ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        thickness: 0.5,
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
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

  /// Smooth radial-inspired gradient background.
  /// Light: soft lavender → warm white.
  /// Dark: deep navy → rich charcoal with indigo undertones.
  static LinearGradient backgroundGradient(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isLight
          ? [
              const Color(0xFFF0F0FF),
              const Color(0xFFF8F9FC),
              const Color(0xFFEFF8F6),
            ]
          : [
              const Color(0xFF0F1117),
              const Color(0xFF12141F),
              const Color(0xFF101319),
            ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ── Chat-Specific Colors ────────────────────────────────────────────────

  /// User bubble: subtle indigo tint in light, deeper surface in dark.
  static Color userBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFEEEFFF)
        : const Color(0xFF1E2038);
  }

  /// Bot bubble: clean white in light, elevated dark surface.
  static Color botBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF1A1C28);
  }

  /// Text color for user message bubbles.
  static Color userBubbleTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Text color for bot message bubbles.
  static Color botBubbleTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Code block background — rich dark with blue undertones.
  static Color codeBlockColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF1B1B2F)
        : const Color(0xFF0D0E1A);
  }

  /// Code block text color.
  static Color codeBlockTextColor(BuildContext context) {
    return const Color(0xFFCDD6F4);
  }

  /// Accent gradient for premium elements (AI avatar, send button, accents).
  static LinearGradient get accentGradient => const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle shimmer gradient for interactive elements.
  static LinearGradient get shimmerGradient => const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Circular icon container decoration for AppBar icons.
  static BoxDecoration iconContainerDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
      shape: BoxShape.circle,
      border: Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }
}
