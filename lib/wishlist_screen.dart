import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    final items = List<Product>.from(WishlistManager.items);
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist'), actions: [
        if (items.isNotEmpty) IconButton(
          tooltip: 'Clear wishlist',
          onPressed: () => setState(() => WishlistManager.items.clear()),
          icon: const Icon(Icons.delete_sweep_outlined)),
      ]),
      body: items.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white38),
            SizedBox(height: 12), Text('Your wishlist is empty'),
            Text('Tap the heart on a product to save it.'),
          ]))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .67),
            itemBuilder: (_, i) => ProductCard(product: items[i]),
          ),
    );
  }
}
