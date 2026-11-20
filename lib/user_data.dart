import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'db_service.dart';
import 'product.dart';

/// One row of users/{uid}/cart in Firestore.
class CartItem {
  final String docId;
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;
  final int maxQty;

  const CartItem({
    required this.docId, required this.product, required this.quantity,
    this.selectedColor, this.selectedSize, this.maxQty = 99,
  });

  double get total => product.price * quantity;

  factory CartItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    return CartItem(
      docId: doc.id,
      product: Product(
        id: (d['productId'] ?? '').toString(),
        name: (d['name'] ?? '').toString(),
        category: (d['category'] ?? '').toString(),
        price: (d['price'] as num?)?.toDouble() ?? 0,
        image: (d['image'] ?? '').toString(),
      ),
      quantity: (d['quantity'] as num?)?.toInt() ?? 1,
      selectedColor: d['color'] as String?,
      selectedSize: d['size'] as String?,
      maxQty: (d['maxQty'] as num?)?.toInt() ?? 99,
    );
  }
}

/// Cart stored in Firestore (users/{uid}/cart). A live listener keeps [items]
/// in sync, so every screen and the nav-bar badge update automatically.
class CartManager {
  static List<CartItem> items = [];
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  static CollectionReference<Map<String, dynamic>>? _col;

  static void start(String uid) {
    stop();
    _col = Db.userCol(uid, 'cart');
    _sub = _col!.snapshots().listen((snap) {
      items = snap.docs.map(CartItem.fromDoc).toList()
        ..sort((a, b) => a.product.name.compareTo(b.product.name));
      changes.value++;
    }, onError: (_) {});
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
    _col = null;
    items = [];
    changes.value++;
  }

  static Future<void> add({
    required Product product, required int quantity, String? color, String? size,
  }) {
    final col = _col;
    if (col == null) return Future.error(StateError('Please sign in first.'));
    final key = '${product.id}_${color ?? '-'}_${size ?? '-'}_${product.price.toStringAsFixed(0)}';
    return col.doc(key).set({
      'productId': product.id,
      'name': product.name,
      'category': product.category,
      'image': product.image,
      'price': product.price,
      'quantity': FieldValue.increment(quantity),
      'color': color,
      'size': size,
      'maxQty': product.stock,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> setQuantity(CartItem item, int quantity) {
    final col = _col;
    if (col == null) return Future.error(StateError('Please sign in first.'));
    return col.doc(item.docId).update({'quantity': quantity});
  }

  static Future<void> remove(CartItem item) {
    final col = _col;
    if (col == null) return Future.error(StateError('Please sign in first.'));
    return col.doc(item.docId).delete();
  }

  static int quantityOf(String productId) => items
      .where((i) => i.product.id == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  static double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  static int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}

/// Wishlist stored in Firestore (users/{uid}/wishlist).
class WishlistManager {
  static List<Product> items = [];
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  static CollectionReference<Map<String, dynamic>>? _col;

  static void start(String uid) {
    stop();
    _col = Db.userCol(uid, 'wishlist');
    _sub = _col!.snapshots().listen((snap) {
      items = snap.docs.map((doc) {
        final d = doc.data();
        return Product(
          id: doc.id,
          name: (d['name'] ?? '').toString(),
          category: (d['category'] ?? '').toString(),
          price: (d['price'] as num?)?.toDouble() ?? 0,
          image: (d['image'] ?? '').toString(),
          images: [(d['image'] ?? '').toString()],
          stock: (d['stock'] as num?)?.toInt() ?? 0,
        );
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      changes.value++;
    }, onError: (_) {});
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
    _col = null;
    items = [];
    changes.value++;
  }

  static bool contains(Product p) => items.any((e) => e.id == p.id);

  static Future<void> toggle(Product p) {
    final col = _col;
    if (col == null) return Future.error(StateError('Please sign in first.'));
    if (contains(p)) return col.doc(p.id).delete();
    return col.doc(p.id).set({
      'name': p.name, 'category': p.category, 'price': p.price,
      'image': p.image, 'stock': p.stock, 'savedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> clear() async {
    final col = _col;
    if (col == null) return;
    final snap = await col.get();
    final batch = Db.fs.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
