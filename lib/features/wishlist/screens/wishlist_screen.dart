import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../common/widgets/empty_state_widget.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../routes/app_routes.dart';
import '../widgets/wishlist_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider).wishlistIds;
    final allProducts = ref.watch(productProvider).products;

    // Match IDs to get actual Product models
    final wishlistedProducts = allProducts
        .where((product) => wishlistIds.contains(product.id))
        .toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.wishlistTitle.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            if (wishlistedProducts.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                tooltip: AppStrings.clearAll,
                onPressed: () => _showClearConfirmation(context, ref),
              ),
          ],
        ),
      
        body: wishlistedProducts.isEmpty
            ? EmptyStateWidget(
                icon: Icons.favorite_border_rounded,
                title: AppStrings.wishlistEmpty,
                subtitle: AppStrings.wishlistEmptySubtitle,
                buttonText: AppStrings.browseProducts,
                onPressed: () => Navigator.pop(context),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: wishlistedProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlistedProducts[index];
      
                  return Dismissible(
                    key: ValueKey(product.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.p16),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSizes.p24),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.onError, size: 30),
                    ),
                    onDismissed: (direction) {
                      ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} removed'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'UNDO',
                            textColor: AppColors.onPrimary,
                            onPressed: () {
                              ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                            },
                          ),
                        ),
                      );
                    },
                    child: WishlistCard(
                      product: product,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productDetail,
                          arguments: product.id,
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist?'),
        content: const Text('Are you sure you want to remove all items?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.neutral)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: const Text(AppStrings.clearAll, style: TextStyle(color: AppColors.onError)),
          ),
        ],
      ),
    );
  }
}