import 'package:flutter/material.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'auth_service.dart';
import 'db_service.dart';
import 'login_screen.dart';
import 'main.dart';
import 'product_grid.dart';

/// Second user type: store admin. Manages products and orders.
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [AdminDashboard(), AdminProductsScreen(), AdminOrdersScreen()];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('D-MART', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: DMartApp.lime, borderRadius: BorderRadius.circular(6)),
            child: const Text('ADMIN', style: TextStyle(color: DMartApp.black, fontSize: 10, fontWeight: FontWeight.w900))),
        ]),
        actions: [
          IconButton(tooltip: 'Log out', icon: const Icon(Icons.logout_rounded, color: DMartApp.lime),
            onPressed: () => confirmAndLogout(context)),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
        ],
      ),
    );
  }
}

/// Database-generated summaries (Firestore count + sum aggregate queries).
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, num>> _future = _load();

  Future<Map<String, num>> _load() async {
    // First admin sign-in on an empty database loads the sample catalogue.
    await Db.seedSampleProducts();
    return Db.adminSummary();
  }

  Widget _card(IconData icon, String value, String label, {Color? color}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: DMartApp.panel, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DMartApp.muted)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color ?? DMartApp.lime),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
      );

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        color: DMartApp.lime,
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<Map<String, num>>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) {
              return ListView(children: [
                const SizedBox(height: 80),
                StateMessage(icon: Icons.cloud_off_rounded, text: Db.errorText(snap.error!)),
                Center(child: FilledButton(
                  onPressed: () => setState(() => _future = _load()), child: const Text('RETRY'))),
              ]);
            }
            if (!snap.hasData) {
              return ListView(children: const [
                SizedBox(height: 140), Center(child: CircularProgressIndicator(color: DMartApp.lime))]);
            }
            final d = snap.data!;
            String money(num n) => 'UGX ${n.toStringAsFixed(0)}';
            return ListView(padding: const EdgeInsets.all(16), children: [
              Text('Hello, ${AuthService.current?.name ?? 'Admin'}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('Live figures from your Firestore database. Pull down to refresh.',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.45,
                children: [
                  _card(Icons.payments_outlined, money(d['revenue'] ?? 0), 'Revenue (delivered)'),
                  _card(Icons.shopping_bag_outlined, money(d['orderValue'] ?? 0), 'Total order value'),
                  _card(Icons.inventory_2_outlined, '${d['products']}', 'Products'),
                  _card(Icons.warning_amber_rounded, '${d['lowStock']}', 'Low stock (under 5)', color: Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Orders by status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.1,
                children: [
                  _card(Icons.hourglass_bottom_rounded, '${d['Pending']}', 'Pending', color: Colors.orangeAccent),
                  _card(Icons.local_shipping_outlined, '${d['Processing']}', 'Processing', color: Colors.lightBlueAccent),
                  _card(Icons.check_circle_outline, '${d['Delivered']}', 'Delivered'),
                  _card(Icons.cancel_outlined, '${d['Cancelled']}', 'Cancelled', color: Colors.redAccent),
                ],
              ),
            ]);
          },
        ),
      );
}
