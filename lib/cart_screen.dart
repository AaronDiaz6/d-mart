import 'package:flutter/material.dart';
import 'product.dart';
import 'main.dart';
import 'checkout_screen.dart';
import 'product_image.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? selectedColor;
  final String? selectedSize;

  CartItem({required this.product, required this.quantity, this.selectedColor, this.selectedSize});
  double get total => product.price * quantity;
}

class CartManager {
  static final List<CartItem> items = [];
  /// Bumps whenever the cart changes so the nav-bar badge updates live.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static void notify() => changes.value++;

  static void add({required Product product, required int quantity, String? color, String? size}) {
    final existing = items.where((item) => item.product.id == product.id &&
      item.product.price == product.price &&
      item.selectedColor == color && item.selectedSize == size);
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity, selectedColor: color, selectedSize: size));
    }
    notify();
  }

  static void remove(CartItem item) { items.remove(item); notify(); }
  static double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  static int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  static void clear() { items.clear(); notify(); }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final items = CartManager.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: items.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 12), Text('Your cart is empty'),
            Text('Add a product to start shopping.'),
          ]))
        : Column(children: [
            Expanded(child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                return Card(child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(9),
                      child: ProductImage(url: item.product.image, label: item.product.name, category: item.product.category, width: 82, height: 90)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (item.selectedColor != null) Text('Colour: ${item.selectedColor}'),
                      if (item.selectedSize != null) Text('Size: ${item.selectedSize}'),
                      Text('UGX ${item.product.price.toStringAsFixed(0)}'),
                      Row(children: [
                        IconButton(onPressed: item.quantity > 1 ? () => setState(() { item.quantity--; CartManager.notify(); }) : null,
                          icon: const Icon(Icons.remove_circle_outline)),
                        Text('${item.quantity}'),
                        IconButton(onPressed: () => setState(() { item.quantity++; CartManager.notify(); }),
                          icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    ])),
                    Column(children: [
                      IconButton(onPressed: () => setState(() => CartManager.remove(item)),
                        icon: const Icon(Icons.delete_outline, color: Colors.red)),
                      Text('UGX ${item.total.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                  ]),
                ));
              },
            )),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: DMartApp.panel, boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)]),
              child: SafeArea(top: false, child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Items: ${CartManager.totalQuantity}'),
                  Text('Subtotal: UGX ${CartManager.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                    if (mounted) setState(() {});
                  },
                  child: const Text('Proceed to checkout'),
                )),
              ])),
            ),
          ]),
    );
  }
}
