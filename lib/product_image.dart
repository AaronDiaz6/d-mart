import 'package:flutter/material.dart';
import 'main.dart';
import 'products.dart';

/// Network product photo with a loading spinner and a clean, labelled
/// fallback (category icon + product name) if the photo cannot load.
class ProductImage extends StatelessWidget {
  final String url;
  final String label;
  final String category;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.url,
    required this.label,
    required this.category,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                width: width, height: height, color: DMartApp.panel,
                child: const Center(child: SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: DMartApp.lime)))),
        errorBuilder: (_, __, ___) => Container(
          width: width, height: height, color: DMartApp.panel,
          padding: const EdgeInsets.all(6),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(categoryIcon(category), color: DMartApp.lime, size: 30),
            const SizedBox(height: 6),
            Text(label, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ]),
        ),
      );
}
