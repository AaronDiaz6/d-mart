import 'package:flutter/material.dart';
import 'db_service.dart';
import 'main.dart';
import 'my_orders_screen.dart';
import 'order_confirmation_screen.dart';
import 'product_grid.dart';

/// Admin: view all customer orders, filter by status, update status, delete.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String? _status;
  late Stream<List<OrderRecord>> _stream = Db.adminOrders();

  void _filter(String? s) => setState(() {
        _status = s;
        _stream = Db.adminOrders(status: s);
      });

  Future<void> _setStatus(OrderRecord o, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Db.updateOrderStatus(o.id, status);
      messenger.showSnackBar(SnackBar(content: Text('Order marked $status')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
    }
  }

  Future<void> _delete(OrderRecord o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete order?'),
        content: Text('Order #${o.orderNumber} will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
        ],
      ),
    );
    if (ok != true) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Db.deleteOrder(o.id);
      messenger.showSnackBar(const SnackBar(content: Text('Order deleted')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(height: 56, child: ListView(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            for (final s in [null, ...orderStatuses])
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(
                label: Text(s ?? 'All'), selected: _status == s, selectedColor: DMartApp.lime,
                labelStyle: TextStyle(color: _status == s ? DMartApp.black : Colors.white, fontWeight: FontWeight.w700),
                onSelected: (_) => _filter(s))),
          ],
        )),
        Expanded(child: StreamBuilder<List<OrderRecord>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) return StateMessage(icon: Icons.cloud_off_rounded, text: Db.errorText(snap.error!));
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: DMartApp.lime));
            final orders = snap.data!;
            if (orders.isEmpty) {
              return const StateMessage(icon: Icons.receipt_long_outlined, text: 'No orders found.');
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(margin: const EdgeInsets.only(bottom: 10), child: ExpansionTile(
                  shape: const Border(),
                  title: Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [
                    StatusChip(o.status), const SizedBox(width: 8),
                    Expanded(child: Text('${o.customerName} • ${formatDate(o.date)}',
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12))),
                  ])),
                  trailing: Text('UGX ${o.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${o.customerName} • ${o.phone}', style: const TextStyle(color: Colors.white70)),
                    Text('${o.address}, ${o.city}', style: const TextStyle(color: Colors.white70)),
                    Text(o.paymentMethod, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const Divider(),
                    for (final it in o.items)
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
                        Expanded(child: Text('${it.quantity} × ${it.productName}')),
                        Text('UGX ${it.total.toStringAsFixed(0)}'),
                      ])),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Status: '),
                      DropdownButton<String>(
                        value: o.status,
                        items: [for (final s in orderStatuses) DropdownMenuItem(value: s, child: Text(s))],
                        onChanged: (v) { if (v != null && v != o.status) _setStatus(o, v); }),
                      const Spacer(),
                      IconButton(tooltip: 'Delete order', onPressed: () => _delete(o),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                    ]),
                  ],
                ));
              },
            );
          },
        )),
      ]);
}
