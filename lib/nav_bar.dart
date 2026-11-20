import 'package:flutter/material.dart';
import 'main.dart';
import 'cart_screen.dart';

class _NavItem {
  final IconData idle;
  final IconData active;
  final String label;
  const _NavItem(this.idle, this.active, this.label);
}

/// Icon-only bottom bar. The tapped icon rises into a lime "bump" above the
/// bar, the bar curves around it, and only then is its label shown.
class DMartNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const DMartNavBar({super.key, required this.index, required this.onTap});

  static const List<_NavItem> _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
    _NavItem(Icons.bolt_outlined, Icons.bolt_rounded, 'Flash'),
    _NavItem(Icons.favorite_border_rounded, Icons.favorite_rounded, 'Wishlist'),
    _NavItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Cart'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  static const double _bar = 62;      // height of the bar itself
  static const double _overhang = 26; // how far the bump rises above the bar
  static const int _cartIndex = 4;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ValueListenableBuilder<int>(
      valueListenable: CartManager.changes,
      builder: (context, _, __) {
        final cartCount = CartManager.totalQuantity;
        return LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          final seg = w / _items.length;
          final targetX = seg * index + seg / 2;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: targetX),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, x, _) {
              return SizedBox(
                height: _overhang + _bar + bottomInset,
                child: Stack(clipBehavior: Clip.none, children: [
                  // bar with a curved cut-out following the bump
                  Positioned.fill(child: CustomPaint(
                    painter: _BarPainter(x: x, top: _overhang))),
                  // idle icons (the selected slot is left empty: its icon is in the bump)
                  Positioned(left: 0, right: 0, top: _overhang, height: _bar,
                    child: Row(children: List.generate(_items.length, (i) {
                      final selected = i == index;
                      return Expanded(child: Semantics(
                        button: true, selected: selected, label: _items[i].label,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(i),
                          child: Center(child: selected
                            ? const SizedBox.shrink()
                            : _badge(Icon(_items[i].idle, color: Colors.white60, size: 25),
                                i == _cartIndex ? cartCount : 0)),
                        ),
                      ));
                    }))),
                  // raised lime bump holding the active icon
                  Positioned(left: x - 27, top: 3, width: 54, height: 54,
                    child: IgnorePointer(child: Container(
                      decoration: BoxDecoration(
                        color: DMartApp.lime, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: DMartApp.lime.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 4))]),
                      child: Center(child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(index),
                          child: _badge(Icon(_items[index].active, color: DMartApp.black, size: 28),
                              index == _cartIndex ? cartCount : 0, onLime: true)),
                      )),
                    ))),
                  // label appears only for the tapped icon
                  Positioned(left: x - 45, width: 90, top: _overhang + 34,
                    child: IgnorePointer(child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(_items[index].label, key: ValueKey(index),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: DMartApp.lime, fontSize: 11,
                          fontWeight: FontWeight.w800, letterSpacing: .4)),
                    ))),
                ]),
              );
            },
          );
        });
      },
    );
  }

  Widget _badge(Widget icon, int count, {bool onLime = false}) {
    if (count <= 0) return icon;
    return Stack(clipBehavior: Clip.none, children: [
      icon,
      Positioned(right: -8, top: -6, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        constraints: const BoxConstraints(minWidth: 17),
        decoration: BoxDecoration(
          color: onLime ? DMartApp.black : DMartApp.lime,
          borderRadius: BorderRadius.circular(10)),
        child: Text(count > 99 ? '99+' : '$count', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
            color: onLime ? DMartApp.lime : DMartApp.black)))),
    ]);
  }
}

class _BarPainter extends CustomPainter {
  final double x;
  final double top;
  _BarPainter({required this.x, required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    const dip = 36.0;
    final path = Path()
      ..moveTo(0, top)
      ..lineTo(x - 44, top)
      ..cubicTo(x - 26, top, x - 32, top + dip, x, top + dip)
      ..cubicTo(x + 32, top + dip, x + 26, top, x + 44, top)
      ..lineTo(size.width, top)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black, 6, false);
    canvas.drawPath(path, Paint()..color = DMartApp.panel);
    canvas.drawLine(Offset(0, top), Offset(x - 44, top),
        Paint()..color = DMartApp.muted..strokeWidth = 1);
    canvas.drawLine(Offset(x + 44, top), Offset(size.width, top),
        Paint()..color = DMartApp.muted..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.x != x || old.top != top;
}
