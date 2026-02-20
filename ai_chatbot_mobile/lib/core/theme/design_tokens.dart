import 'package:flutter/material.dart';

/// Design tokens defining the visual foundation of the app.
///
/// Modern AI SaaS design system based on an 8px grid with generous
/// spacing and large border radii for a premium, breathable feel.
/// Usage: `DesignTokens.spacing.md` for medium spacing, etc.
class DesignTokens {
  DesignTokens._();

  // ── Spacing (8px grid) ──────────────────────────────────────────────────

  static const spacing = _Spacing();

  // ── Border Radius ───────────────────────────────────────────────────────

  static const borderRadius = _BorderRadius();

  // ── Typography Scales ───────────────────────────────────────────────────

  static const typography = _Typography();

  // ── Elevation ───────────────────────────────────────────────────────────

  static const elevation = _Elevation();

  // ── Icon Sizes ──────────────────────────────────────────────────────────

  static const iconSize = _IconSize();

  // ── Animation Durations ─────────────────────────────────────────────────

  static const animation = _Animation();

  // ── Chat-Specific Tokens ────────────────────────────────────────────────

  static const chat = _ChatTokens();
}

/// Spacing tokens based on an 8px grid system.
class _Spacing {
  const _Spacing();

  /// 2px – Hairline spacing.
  double get xxxs => 2.0;

  /// 4px – Extra extra small spacing.
  double get xxs => 4.0;

  /// 8px – Extra small spacing.
  double get xs => 8.0;

  /// 12px – Small spacing.
  double get sm => 12.0;

  /// 16px – Medium spacing (1 grid unit × 2).
  double get md => 16.0;

  /// 20px – Medium-large spacing.
  double get mdLg => 20.0;

  /// 24px – Large spacing (3 grid units).
  double get lg => 24.0;

  /// 32px – Extra large spacing (4 grid units).
  double get xl => 32.0;

  /// 40px – Extra extra large spacing.
  double get xxl => 40.0;

  /// 48px – Triple extra large spacing.
  double get xxxl => 48.0;

  /// 64px – Huge spacing.
  double get huge => 64.0;
}

/// Border radius tokens — modern, generous rounding.
class _BorderRadius {
  const _BorderRadius();

  /// No rounding.
  BorderRadius get none => BorderRadius.zero;

  /// 4px – Subtle rounding.
  BorderRadius get xs => BorderRadius.circular(4.0);

  /// 8px – Small rounding.
  BorderRadius get sm => BorderRadius.circular(8.0);

  /// 12px – Medium rounding.
  BorderRadius get md => BorderRadius.circular(12.0);

  /// 16px – Large rounding (cards, containers).
  BorderRadius get lg => BorderRadius.circular(16.0);

  /// 20px – Extra large rounding (message bubbles).
  BorderRadius get xl => BorderRadius.circular(20.0);

  /// 24px – Extra extra large rounding (inputs, prominent elements).
  BorderRadius get xxl => BorderRadius.circular(24.0);

  /// Full circle rounding (pills, circular buttons).
  BorderRadius get full => BorderRadius.circular(999.0);
}

/// Typography scale tokens.
class _Typography {
  const _Typography();

  /// 10px – Caption / smallest text.
  double get caption => 10.0;

  /// 12px – Small body text, labels.
  double get bodySmall => 12.0;

  /// 14px – Default body text.
  double get bodyMedium => 14.0;

  /// 16px – Large body text.
  double get bodyLarge => 16.0;

  /// 18px – Subtitle text.
  double get subtitle => 18.0;

  /// 20px – Title text.
  double get titleSmall => 20.0;

  /// 22px – Medium title.
  double get titleMedium => 22.0;

  /// 24px – Large title.
  double get titleLarge => 24.0;

  /// 28px – Headline.
  double get headline => 28.0;

  /// 32px – Display text.
  double get display => 32.0;
}

/// Elevation tokens for shadow depth.
class _Elevation {
  const _Elevation();

  /// No elevation.
  double get none => 0.0;

  /// 1px – Subtle elevation (cards).
  double get xs => 1.0;

  /// 2px – Low elevation.
  double get sm => 2.0;

  /// 4px – Medium elevation (floating buttons).
  double get md => 4.0;

  /// 8px – High elevation (modals).
  double get lg => 8.0;

  /// 16px – Highest elevation.
  double get xl => 16.0;
}

/// Icon size tokens.
class _IconSize {
  const _IconSize();

  /// 14px – Tiny icons.
  double get xs => 14.0;

  /// 16px – Small icons.
  double get sm => 16.0;

  /// 20px – Medium-small icons.
  double get md => 20.0;

  /// 24px – Default Material icon size.
  double get lg => 24.0;

  /// 32px – Large icons.
  double get xl => 32.0;

  /// 48px – Extra large icons (empty states).
  double get xxl => 48.0;

  /// 64px – Hero icons.
  double get hero => 64.0;
}

/// Animation duration tokens.
class _Animation {
  const _Animation();

  /// 100ms – Micro interactions (ripples, toggles).
  Duration get instant => const Duration(milliseconds: 100);

  /// 200ms – Fast transitions (fade in/out).
  Duration get fast => const Duration(milliseconds: 200);

  /// 300ms – Standard transitions.
  Duration get normal => const Duration(milliseconds: 300);

  /// 400ms – Medium transitions (slide-ins).
  Duration get medium => const Duration(milliseconds: 400);

  /// 500ms – Slow transitions (page transitions).
  Duration get slow => const Duration(milliseconds: 500);

  /// 800ms – Very slow (typing indicator).
  Duration get verySlow => const Duration(milliseconds: 800);

  /// Standard easing curve for entrance animations.
  Curve get entranceCurve => Curves.easeOutCubic;

  /// Deceleration curve for exit animations.
  Curve get exitCurve => Curves.easeInCubic;
}

/// Chat-specific design tokens.
class _ChatTokens {
  const _ChatTokens();

  /// Maximum bubble width as fraction of screen width.
  double get maxBubbleWidthFraction => 0.82;

  /// User bubble border radius — 26px uniform rounded bubble.
  BorderRadius get userBubbleRadius => const BorderRadius.only(
    topLeft: Radius.circular(26),
    topRight: Radius.circular(26),
    bottomLeft: Radius.circular(26),
    bottomRight: Radius.circular(8),
  );

  /// Bot bubble border radius — 26px uniform rounded bubble.
  BorderRadius get botBubbleRadius => const BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(26),
    bottomLeft: Radius.circular(26),
    bottomRight: Radius.circular(26),
  );

  /// Internal padding for both user and bot bubbles — 16px.
  EdgeInsets get bubblePadding => const EdgeInsets.all(16);

  /// Vertical spacing between messages.
  double get messageSpacing => 18.0;
}
