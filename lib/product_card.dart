import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'product_image.dart';
import 'product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final saved = WishlistManager.contains(product);
    void open() => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                InkWell(
                  onTap: open,
                  child: ProductImage(url: product.image, label: product.name, category: product.category),
                ),
                if (product.onSale)
                  Positioned(left: 6, top: 6, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: DMartApp.lime, borderRadius: BorderRadius.circular(8)),
                    child: Text('-${product.discountPercent}%',
                      style: const TextStyle(color: DMartApp.black, fontWeight: FontWeight.w900, fontSize: 11)))),
                Positioned(
                  top: 6, right: 6,
                  child: CircleAvatar(
                    backgroundColor: DMartApp.lime,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? Colors.red : DMartApp.black, size: 20),
                      onPressed: () {
                        setState(() => WishlistManager.toggle(product));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(saved ? 'Removed from wishlist' : 'Added to wishlist'),
                          duration: const Duration(seconds: 1),
                        ));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 2),
            child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Row(children: [
              Text('UGX ${product.price.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold,
                  color: product.onSale ? DMartApp.lime : Colors.white)),
              if (product.onSale) ...[
                const SizedBox(width: 6),
                Flexible(child: Text(product.oldPrice!.toStringAsFixed(0),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11,
                    decoration: TextDecoration.lineThrough))),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
            child: SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: open,
              child: const Text('View product'),
            )),
          ),
        ],
      ),
    );
  }
}
