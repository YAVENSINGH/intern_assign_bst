import 'package:flutter/material.dart';

/// App color palette — Modern Minimalist E-Commerce
/// Primary: Dark Navy #111827
/// Secondary: Vibrant Orange #FF6B35
/// Tertiary: Deep Brown #231604
/// Neutral: Grey #787778
class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Primary (Dark Navy) ───────────────────────────
  static const Color primary = Color(0xFF111827);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF2D3748);
  static const Color primaryContainer = Color(0xFFD1D5DB);
  static const Color onPrimaryContainer = Color(0xFF111827);

  // ─── Secondary (Vibrant Orange) ────────────────────
  static const Color secondary = Color(0xFFFF6B35);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFFFF8F5E);
  static const Color secondaryDark = Color(0xFFE55A24);
  static const Color secondaryContainer = Color(0xFFFFDBCB);
  static const Color onSecondaryContainer = Color(0xFF3A0B00);

  // ─── Tertiary (Deep Brown) ─────────────────────────
  static const Color tertiary = Color(0xFF231604);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryLight = Color(0xFF4A3520);
  static const Color tertiaryContainer = Color(0xFFD4C4B0);

  // ─── Neutral (Grey) ───────────────────────────────
  static const Color neutral = Color(0xFF787778);
  static const Color neutralLight = Color(0xFFA8A7A8);
  static const Color neutralDark = Color(0xFF4A494A);

  // ─── Surface & Background ─────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color background = Color(0xFFF9FAFB);

  // ─── Cards ─────────────────────────────────────────
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);

  // ─── Error ─────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // ─── Semantic Colors ───────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // ─── Rating ────────────────────────────────────────
  static const Color ratingActive = Color(0xFFFF6B35);
  static const Color ratingInactive = Color(0xFFD1D5DB);

  // ─── Wishlist ──────────────────────────────────────
  static const Color wishlistActive = Color(0xFFDC2626);
  static const Color wishlistInactive = Color(0xFF787778);

  // ─── Discount Badge ────────────────────────────────
  static const Color discountBadge = Color(0xFF16A34A);
  static const Color onDiscountBadge = Color(0xFFFFFFFF);

  // ─── Text Colors ───────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ─── Shimmer ───────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  // ─── Divider & Border ──────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);

  // ─── Misc ──────────────────────────────────────────
  static const Color shadow = Color(0x0F000000);
  static const Color overlay = Color(0x80111827);
  static const Color transparent = Colors.transparent;
  static const Color scrim = Color(0x33111827);
}
