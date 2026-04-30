import 'package:flutter/material.dart';

enum LoadingType { fullScreen, inline, overlay }

class AppLoadingWidget extends StatelessWidget {
  final LoadingType type;

  const AppLoadingWidget._({super.key, required this.type});

  // Factory constructors for clean usage
  factory AppLoadingWidget.fullScreen() =>
      const AppLoadingWidget._(type: LoadingType.fullScreen);

  factory AppLoadingWidget.inline() =>
      const AppLoadingWidget._(type: LoadingType.inline);

  factory AppLoadingWidget.overlay() =>
      const AppLoadingWidget._(type: LoadingType.overlay);

  @override
  Widget build(BuildContext context) {
    final loader = const CircularProgressIndicator();

    switch (type) {
      case LoadingType.fullScreen:
      // Pura screen white/black hoke center mein loader aayega
        return Scaffold(
          body: Center(child: loader),
        );

      case LoadingType.inline:
      // Pagination ke liye (list ke end mein chota sa loader)
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: loader,
          ),
        );

      case LoadingType.overlay:
      // Stack ke upar transparent black background ke sath (Like add to cart loading)
        return Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: loader,
            ),
          ),
        );
    }
  }
}