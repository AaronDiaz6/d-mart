import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'db_service.dart';
import 'main.dart';
import 'order_confirmation_screen.dart';
import 'product_grid.dart';

Color statusColor(String s) {
  switch (s) {
    case 'Delivered':
      return DMartApp.lime;
    case 'Processing':
      return Colors.lightBlueAccent;
    case 'Cancelled':
      return Colors.redAccent;
    default:
      return Colors.orangeAccent;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: statusColor(status).withOpacity(.15), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor(status))),
        child: Text(status, style: TextStyle(color: statusColor(status), fontSize: 11, fontWeight: FontWeight.w800)),
      );
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late final Stream<List<OrderRecord>> _stream = Db.userOrders(AuthService.current?.uid ?? '');

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title), content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('NO')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(action)),
          ],
        ),
      ) ?? false;

  Future<void> _cancel(OrderRecord o) async {
    if (!await _confirm('Cancel order?', 'Order #${o.orderNumber} will be cancelled and the items returned to stock.', 'CANCEL ORDER')) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Db.cancelOrder(o);
      messenger.showSnackBar(const SnackBar(content: Text('Order cancelled')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
    }
  }

  Future<void> _delete(OrderRecord o) async {
    if (!await _confirm('Delete order record?', 'This removes #${o.orderNumber} from your history.', 'DELETE')) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Db.deleteOrder(o.id);
      messenger.showSnackBar(const SnackBar(content: Text('Order record deleted')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: StreamBuilder<List<OrderRecord>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const StateMessage(icon: Icons.cloud_off_rounded,
                text: 'Could not load your orders. Check your internet connection.');
            }
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: DMartApp.lime));
            final orders = snap.data!;
            if (orders.isEmpty) {
              return const StateMessage(icon: Icons.receipt_long_outlined,
                text: 'You have not placed any orders yet.');
            }
            final active = orders.where((o) => o.status != 'Cancelled');
            final value = active.fold<double>(0, (s, o) => s + o.total);
            return ListView(padding: const EdgeInsets.all(14), children: [
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${orders.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: DMartApp.lime)),
                  const Text('Orders', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('UGX ${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DMartApp.lime)),
                  const Text('Total value (excl. cancelled)', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ])),
              ]))),
              const SizedBox(height: 8),
              for (final o in orders)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [
                      StatusChip(o.status), const SizedBox(width: 8),
                      Text(formatDate(o.date), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ])),
                    trailing: Text('UGX ${o.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${o.customerName} • ${o.phone}', style: const TextStyle(color: Colors.white70)),
                      Text('${o.address}, ${o.city}', style: const TextStyle(color: Colors.white70)),
                      Text(o.paymentMethod, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const Divider(),
                      for (final i in o.items)
                        Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
                          Expanded(child: Text('${i.quantity} × ${i.productName}'
                            '${i.color == null ? '' : ' • ${i.color}'}${i.size == null ? '' : ' • ${i.size}'}')),
                          Text('UGX ${i.total.toStringAsFixed(0)}'),
                        ])),
                      if (o.status == 'Pending' || o.status == 'Cancelled')
                        Align(alignment: Alignment.centerRight, child: o.status == 'Pending'
                          ? TextButton.icon(onPressed: () => _cancel(o),
                              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                              label: const Text('Cancel order', style: TextStyle(color: Colors.redAccent)))
                          : TextButton.icon(onPressed: () => _delete(o),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              label: const Text('Delete record', style: TextStyle(color: Colors.redAccent)))),
                    ],
                  ),
                ),
            ]);
          },
        ),
      );
}
