import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'products.dart';
import 'product_card.dart';
import 'product_image.dart';
import 'product_details_screen.dart';

/// Live HH:MM:SS countdown to the next flash-sale reset.
class FlashCountdown extends StatefulWidget {
  const FlashCountdown({super.key});
  @override
  State<FlashCountdown> createState() => _FlashCountdownState();
}

class _FlashCountdownState extends State<FlashCountdown> {
  Timer? _timer;
  Duration _left = flashTimeLeft();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _left = flashTimeLeft());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _chip(int v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(color: DMartApp.lime, borderRadius: BorderRadius.circular(6)),
        child: Text(v.toString().padLeft(2, '0'),
            style: const TextStyle(color: DMartApp.black, fontWeight: FontWeight.w900, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    const colon = Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(':', style: TextStyle(color: DMartApp.lime, fontWeight: FontWeight.w900)));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _chip(_left.inHours), colon, _chip(_left.inMinutes % 60), colon, _chip(_left.inSeconds % 60),
    ]);
  }
}

/// Auto-running flash-sale carousel (advances by itself every 3 seconds).
class FlashSaleStrip extends StatefulWidget {
  final double height;
  const FlashSaleStrip({super.key, this.height = 160});
  @override
  State<FlashSaleStrip> createState() => _FlashSaleStripState();
}

class _FlashSaleStripState extends State<FlashSaleStrip> {
  final PageController _controller = PageController(viewportFraction: .88);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients) return;
      final next = ((_controller.page ?? 0).round() + 1) % flashSales.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  int _claimed(Product p) => 35 + (p.id * 7) % 55; // static "% claimed" for display

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _controller,
          itemCount: flashSales.length,
          itemBuilder: (context, i) {
            final p = flashSales[i];
            final claimed = _claimed(p);
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p))),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: DMartApp.panel, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DMartApp.muted)),
                clipBehavior: Clip.antiAlias,
                child: Row(children: [
                  SizedBox(width: widget.height * .85, height: double.infinity, child: Stack(fit: StackFit.expand, children: [
                    ProductImage(url: p.image, label: p.name, category: p.category),
                    Positioned(left: 8, top: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: DMartApp.lime, borderRadius: BorderRadius.circular(8)),
                      child: Text('-${p.discountPercent}%',
                        style: const TextStyle(color: DMartApp.black, fontWeight: FontWeight.w900, fontSize: 12)))),
                  ])),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(children: const [
                        Icon(Icons.bolt_rounded, color: DMartApp.lime, size: 15),
                        Text('FLASH SALE', style: TextStyle(color: DMartApp.lime,
                          fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 4),
                      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('UGX ${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: DMartApp.lime)),
                      Text('UGX ${p.oldPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11,
                          decoration: TextDecoration.lineThrough)),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                        value: claimed / 100, minHeight: 6,
                        backgroundColor: DMartApp.muted, color: DMartApp.lime)),
                      const SizedBox(height: 3),
                      Text('$claimed% claimed', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ]),
                  )),
                ]),
              ),
            );
          },
        ),
      );
}

/// Full flash-sales tab.
class FlashSalesScreen extends StatelessWidget {
  const FlashSalesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            Icon(Icons.bolt_rounded, color: DMartApp.lime),
            SizedBox(width: 4),
            Text('Flash sales', style: TextStyle(fontWeight: FontWeight.w900)),
          ]),
          actions: const [Center(child: FlashCountdown()), SizedBox(width: 16)],
        ),
        body: CustomScrollView(slivers: [
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Text('Deals end when the timer hits zero. New deals drop every 6 hours.',
              style: TextStyle(color: Colors.white60, fontSize: 12)))),
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.only(left: 16), child: FlashSaleStrip(height: 170))),
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Text('All deals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: flashSales[i]), childCount: flashSales.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: .62))),
        ]),
      );
}
