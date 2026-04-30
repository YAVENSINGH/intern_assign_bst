import 'package:flutter/material.dart';

/// String extensions
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalizes first letter of each word.
  String get titleCase =>
      split(' ').map((word) => word.capitalize).join(' ');
}

/// Num extensions for price formatting
extension NumExtension on num {
  /// Formats number as price with currency symbol.
  /// Example: 999.5 → "₹999.50"
  String get toPriceString => '₹${toStringAsFixed(2)}';

  /// Formats number as compact price (no decimals if .00).
  /// Example: 999.0 → "₹999", 999.5 → "₹999.50"
  String get toCompactPrice {
    if (this == toInt()) {
      return '₹${toInt()}';
    }
    return '₹${toStringAsFixed(2)}';
  }

  /// Calculates discount percentage.
  /// Usage: originalPrice.discountPercent(discountedPrice)
  int discountPercent(num discountedPrice) {
    if (this <= 0) return 0;
    return (((this - discountedPrice) / this) * 100).round();
  }
}

/// BuildContext extensions for quick access
extension ContextExtension on BuildContext {
  /// Quick access to ThemeData
  ThemeData get theme => Theme.of(this);

  /// Quick access to TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to MediaQuery size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => screenSize.width;

  /// Screen height
  double get screenHeight => screenSize.height;

  /// Show a SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : null,
      ),
    );
  }
}
