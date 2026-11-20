import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'product_card.dart';

/// Icon + message used for empty and error states.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  const StateMessage({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 52, color: Colors.white38),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
          ]),
        ),
      );
}

/// Grid of ProductCards fed by a live Firestore stream, with loading,
/// empty and error states built in.
class ProductGridView extends StatelessWidget {
  final Stream<List<Product>> stream;
  final List<Product> Function(List<Product>)? transform;
  final String emptyMessage;
  final bool shrink;
  final double aspect;
  final EdgeInsets padding;

  const ProductGridView({
    super.key,
    required this.stream,
    this.transform,
    this.emptyMessage = 'No products found.',
    this.shrink = false,
    this.aspect = .67,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Product>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const SizedBox(height: 220, child: StateMessage(
              icon: Icons.cloud_off_rounded,
              text: 'Could not load products. Check your internet connection and try again.'));
          }
          if (!snap.hasData) {
            return const SizedBox(height: 220, child: Center(
              child: CircularProgressIndicator(color: DMartApp.lime)));
          }
          final list = transform == null ? snap.data! : transform!(snap.data!);
          if (list.isEmpty) {
            return SizedBox(height: 220, child: StateMessage(icon: Icons.search_off_rounded, text: emptyMessage));
          }
          return GridView.builder(
            padding: padding,
            shrinkWrap: shrink,
            physics: shrink ? const NeverScrollableScrollPhysics() : null,
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: aspect),
            itemBuilder: (_, i) => ProductCard(product: list[i]),
          );
        },
      );
}
