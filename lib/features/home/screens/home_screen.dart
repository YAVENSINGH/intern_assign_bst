import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../common/widgets/empty_state_widget.dart';
import '../../../common/widgets/error_widget.dart';
import '../../../providers/product_provider.dart';
import '../../../routes/app_routes.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ─── INFINITE SCROLL LOGIC ⚙️ ───
    _scrollController.addListener(() {
      // Agar user list ke end se 200 pixels upar hai, toh naya data mangwa lo (Smooth experience)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(productProvider.notifier).fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Memory bachaane ke liye dispose karna zaroori hai
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Providers ko watch kar rahe hain
    final productState = ref.watch(productProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border_rounded),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.wishlist);
              },
            ),
            const SizedBox(width: AppSizes.p8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh feature 🔥
            ref.read(searchQueryProvider.notifier).state = '';
            ref.read(selectedCategoryProvider.notifier).state = null;
            await ref.read(productProvider.notifier).fetchProducts();
          },
          child: Column(
            children: [
              // ─── 1. SEARCH BAR & FILTER BUTTON 🔍🎛️ ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    const Expanded(child: SearchBarWidget()),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: () => showFilterBottomSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
      
              // ─── 2. HORIZONTAL CATEGORY CHIPS 🏷️ ───
              SizedBox(
                height: 50,
                child: categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categories) {
                    // "All Items" ko add karne ke liye ek combined list banayi
                    final allCategories = ['All Items', ...categories];
      
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allCategories.length,
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        // Logic: Agar selectedCategory null hai, toh "All Items" selected maana jayega
                        final isSelected = category == 'All Items'
                            ? selectedCategory == null
                            : category == selectedCategory;
      
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              if (category == 'All Items') {
                                ref.read(selectedCategoryProvider.notifier).state = null;
                                ref.read(productProvider.notifier).fetchProducts();
                              } else {
                                ref.read(selectedCategoryProvider.notifier).state = category;
                                ref.read(productProvider.notifier).filterByCategory(category);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
      
              // ─── 3. MAIN PRODUCT GRID 📦 ───
              Expanded(
                child: _buildMainContent(productState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ye helper method UI ko clean rakhne ke liye hai
  Widget _buildMainContent(ProductState state) {
    // A. Pehli baar load ho raha hai (Skeleton)
    if (state.isLoading && state.products.isEmpty) {
      return const ProductSkeletonGrid();
    }

    // B. Error aa gaya
    if (state.error != null && state.products.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(productProvider.notifier).fetchProducts(),
      );
    }

    // C. Data khali hai (Empty State)
    if (state.products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: AppStrings.noSearchResults,
        subtitle: 'Try adjusting your filters or search query.',
        buttonText: AppStrings.resetFilters,
        onPressed: () {
          ref.read(searchQueryProvider.notifier).state = '';
          ref.read(selectedCategoryProvider.notifier).state = null;
          ref.read(productProvider.notifier).fetchProducts();
        },
      );
    }

    // D. Data mil gaya (GridView)
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // Image height ke hisaab se ratio adjust kiya hai
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.products.length + (state.isLoading ? 2 : 0), // Loader ke liye extra space
      itemBuilder: (context, index) {
        // Agar hum last tak pahunch gaye hain aur API call chal rahi hai, toh bottom mein shimmer dikhao
        if (index >= state.products.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = state.products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: product.id,
            );
          },
        );
      },
    );
  }
}