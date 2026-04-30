import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/wishlist_provider.dart';


// ConsumerWidget use kiya hai taaki sirf ye card wishlist changes sune, poori screen nahi!
class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap; // Navigation parent handle karega (Clean UI)

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🪄 THE MAGIC: Sirf is specific product ka wishlist status watch kar rahe hain
    final isWishlisted = ref.watch(isInWishlistProvider(product.id));

    return GestureDetector(
      onTap: onTap, // Detail screen pe jaane ke liye
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Image Section (With Hero & Heart Icon) 🖼️ ───
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Animation ke liye unique tag zaroori hai
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      // CachedNetworkImage bar-bar image load karne se bachayega
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  // Wishlist Button (Hawa mein tairta hua - Positioned)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // Tap karte hi Action trigger karo!
                          ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isWishlisted ? AppColors.wishlistActive : AppColors.wishlistInactive,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── 2. Details Section (Title, Price, Rating) 📝 ───
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    maxLines: 1, // Ek line se zyada hua toh "..." aayega
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price aur Rating ek hi line mein (Row)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Rating (Star + Number)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.ratingActive),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}