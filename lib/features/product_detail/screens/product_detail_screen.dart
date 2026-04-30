import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../widgets/image_carousel.dart';
import '../widgets/rating_stars.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(isInWishlistProvider(productId));

    // FutureProvider for single product
    final productAsync = ref.watch(_productDetailProvider(productId));

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: productAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppSizes.p16),
                Text(err.toString()),
                const SizedBox(height: AppSizes.p16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_productDetailProvider(productId)),
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
          data: (product) => _buildContent(context, ref, product, isWishlisted),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Product product,
    bool isWishlisted,
  ) {
    return Stack(
      children: [
        // ─── Scrollable Content ───
        CustomScrollView(
          slivers: [
            // ─── 1. AppBar with Hero Image ───
            SliverAppBar(
              expandedHeight: AppSizes.detailImageHeight,
              pinned: true,
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              actions: [
                IconButton(
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? AppColors.wishlistActive : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Share product
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'product_image_${product.id}',
                  child: ImageCarousel(images: product.images),
                ),
              ),
            ),

            // ─── 2. Product Info ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Rating
                    RatingStars(rating: product.rating),
                    const SizedBox(height: AppSizes.p16),

                    // ─── Price Section ───
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Discounted price
                        Text(
                          product.discountedPrice.toCompactPrice,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (product.hasDiscount) ...[
                          const SizedBox(width: AppSizes.p8),
                          // Original price (strikethrough)
                          Text(
                            product.price.toCompactPrice,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          // Discount badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p8,
                              vertical: AppSizes.p4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.discountBadge,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}% ${AppStrings.off}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onDiscountBadge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSizes.p20),

                    // ─── Info Chips ───
                    Wrap(
                      spacing: AppSizes.p8,
                      runSpacing: AppSizes.p8,
                      children: [
                        _infoChip(context, Icons.category_outlined, product.category),
                        if (product.brand.isNotEmpty)
                          _infoChip(context, Icons.business_outlined, product.brand),
                        _infoChip(
                          context,
                          product.inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                          product.inStock ? AppStrings.inStock : AppStrings.outOfStock,
                          color: product.inStock ? AppColors.success : AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p24),

                    // ─── Description ───
                    Text(
                      AppStrings.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),

                    // Bottom padding for the CTA button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── 3. Fixed Bottom CTA Button ───
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p20, AppSizes.p12, AppSizes.p20, AppSizes.p24,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                final msg = isWishlisted
                    ? AppStrings.removeFromWishlist
                    : AppStrings.addToWishlist;
                context.showSnackBar(msg);
              },
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
              ),
              label: Text(
                isWishlisted ? AppStrings.removeFromWishlist : AppStrings.addToWishlist,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isWishlisted ? AppColors.error : AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Info Chip Helper ───
  Widget _infoChip(BuildContext context, IconData icon, String label, {Color? color}) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
      label: Text(
        label.capitalize,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
    );
  }
}

// ─── FutureProvider for single product ───
final _productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.read(productRepositoryProvider).getProductById(id);
});
