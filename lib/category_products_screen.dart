import 'package:flutter/material.dart';
import 'products.dart';
import 'product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = products.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .67),
        itemBuilder: (_, i) => ProductCard(product: items[i]),
      ),
    );
  }
}
