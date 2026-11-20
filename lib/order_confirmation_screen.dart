import 'package:flutter/material.dart';
import 'main.dart';

class OrderItem {
  final String productName;
  final String image;
  final double price;
  final int quantity;
  final String? color;
  final String? size;

  const OrderItem({
    required this.productName, required this.image, required this.price,
    required this.quantity, this.color, this.size,
  });
  double get total => price * quantity;
}

class OrderRecord {
  final String orderNumber;
  final String customerName, phone, address, city, paymentMethod;
  final double total;
  final List<OrderItem> items;
  final DateTime date;

  OrderRecord({
    required this.customerName, required this.phone, required this.address,
    required this.city, required this.paymentMethod, required this.total,
    required this.items,
  }) : date = DateTime.now(),
       orderNumber = 'DM${DateTime.now().millisecondsSinceEpoch}';
}

class OrderHistory {
  static final List<OrderRecord> orders = [];
  static void add(OrderRecord order) => orders.insert(0, order);
}

class OrderConfirmationScreen extends StatelessWidget {
  final OrderRecord order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order confirmation'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 12),
        const CircleAvatar(radius: 38, backgroundColor: DMartApp.lime,
          child: Icon(Icons.check, size: 44, color: DMartApp.black)),
        const SizedBox(height: 14),
        const Center(child: Text('Order placed successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 6),
        Center(child: Text('Order #${order.orderNumber}', style: const TextStyle(color: Colors.white60))),
        const SizedBox(height: 22),
        _section('Delivery details', [
          '${order.customerName} • ${order.phone}',
          order.address,
          order.city,
        ]),
        _section('Payment', [order.paymentMethod]),
        const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...order.items.map((item) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(borderRadius: BorderRadius.circular(8),
            child: Image.network(item.image, width: 52, height: 52, fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(width: 52, height: 52, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              errorBuilder: (_, __, ___) => const SizedBox(width: 52, height: 52, child: Icon(Icons.image_not_supported_outlined)))),
          title: Text(item.productName),
          subtitle: Text('Qty: ${item.quantity}${item.color == null ? '' : ' • ${item.color}'}${item.size == null ? '' : ' • ${item.size}'}'),
          trailing: Text('UGX ${item.total.toStringAsFixed(0)}'),
        )),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Order total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('UGX ${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 22),
        FilledButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text('Continue shopping')),
      ]),
    );
  }

  Widget _section(String title, List<String> lines) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...lines.map(Text.new),
      ],
    )),
  );
}
