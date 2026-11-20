import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'cart_screen.dart';
import 'product_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int imageIndex = 0;
  int quantity = 1;
  int selectedColor = 0;
  int selectedSize = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images.isNotEmpty ? p.images : [p.image];
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => imageIndex = i),
              itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 60))),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(images.length, (i) =>
            Container(width: 7, height: 7, margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: i == imageIndex ? DMartApp.lime : Colors.white30)))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.category.toUpperCase(), style: const TextStyle(color: Colors.white60, letterSpacing: 1)),
              const SizedBox(height: 5),
              Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                Text('UGX ${p.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,
                    color: p.onSale ? DMartApp.lime : Colors.white)),
                if (p.onSale) ...[
                  const SizedBox(width: 10),
                  Text('UGX ${p.oldPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white54, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: DMartApp.lime, borderRadius: BorderRadius.circular(8)),
                    child: Text('-${p.discountPercent}%',
                      style: const TextStyle(color: DMartApp.black, fontWeight: FontWeight.w900, fontSize: 12))),
                ],
              ]),
              const SizedBox(height: 14),
              Text(p.description),
              if (p.colors.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Colour', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 8, children: List.generate(p.colors.length, (i) =>
                  ChoiceChip(label: Text(p.colors[i]), selected: selectedColor == i,
                    onSelected: (_) => setState(() => selectedColor = i)))),
              ],
              if (p.sizes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 8, children: List.generate(p.sizes.length, (i) =>
                  ChoiceChip(label: Text(p.sizes[i]), selected: selectedSize == i,
                    onSelected: (_) => setState(() => selectedSize = i)))),
              ],
              const SizedBox(height: 18),
              Row(children: [
                const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline)),
                Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add_circle_outline)),
              ]),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to cart'),
                onPressed: () {
                  CartManager.add(product: p, quantity: quantity,
                    color: p.colors.isNotEmpty ? p.colors[selectedColor] : null,
                    size: p.sizes.isNotEmpty ? p.sizes[selectedSize] : null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product added to cart')),
                  );
                },
              )),
            ]),
          ),
        ],
      ),
    );
  }
}
