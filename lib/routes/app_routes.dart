import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/product_detail/screens/product_detail_screen.dart';
import '../features/wishlist/screens/wishlist_screen.dart';

/// Named route constants
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String productDetail = '/product-detail';
  static const String wishlist = '/wishlist';

  /// Route generator — handles all navigation
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case productDetail:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );

      case wishlist:
        return MaterialPageRoute(
          builder: (_) => const WishlistScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
