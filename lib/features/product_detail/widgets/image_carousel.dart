import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({
    super.key,
    required this.images,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Safety check: Agar API se empty list aayi toh UI crash nahi hoga
    if (widget.images.isEmpty) {
      return Container(
        height: 350,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Icons.image_not_supported_rounded, size: 50, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 350, // Standard height detail screen ke liye
      width: double.infinity,
      child: Stack(
        children: [
          // ─── 1. Swipeable Images 🖼️ ───
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover, // Image ko container mein properly fit karega
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade50,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),

          // ─── 2. Dot Indicators 🔴 ───
          // Positioned ka use kiya taaki dots bottom center mein fix rahein
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                    (index) => _buildDot(index, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The Animated Dot Magic 🪄
  Widget _buildDot(int index, BuildContext context) {
    final isActive = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth transition
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      // Active dot thodi lambi (capsule shape) hogi
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        // Active dot par primary color, inactive pe semi-transparent white/grey
        color: isActive ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          // Halki si shadow taaki white images pe dots clearly visible rahein
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
    );
  }
}