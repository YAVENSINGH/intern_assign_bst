import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProductSkeletonGrid extends StatelessWidget {
  final int itemCount;

  const ProductSkeletonGrid({
    super.key,
    this.itemCount = 6, // Default 6 dummy cards dikhayenge
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Parent scroll handle karega
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSizes.gridCrossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppSizes.gridCrossAxisSpacing,
          mainAxisSpacing: AppSizes.gridMainAxisSpacing,
        ),
        itemBuilder: (context, index) {
          return const _SkeletonCard();
        },
      ),
    );
  }
}

/// Private widget kyunki isko hum sirf isi file mein use karenge
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Fake Image Box
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
          ),

          // 2. Fake Text Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSizes.p8),
                // Price placeholder (chhota width)
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSizes.p12),
                // Rating placeholder
                Container(
                  height: 12,
                  width: 50,
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}