import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_confirmation_screen.dart';
import 'product.dart';
import 'products.dart';
import 'user_data.dart';

enum SortOption { relevance, priceLow, priceHigh, nameAZ }

extension SortOptionLabel on SortOption {
  String get label => switch (this) {
        SortOption.relevance => 'Default',
        SortOption.priceLow => 'Price: low to high',
        SortOption.priceHigh => 'Price: high to low',
        SortOption.nameAZ => 'Name: A to Z',
      };
}

/// All Cloud Firestore access for D-Mart lives here.
///
/// Collections:
///   users/{uid}                  profile + role ("customer" | "admin")
///   users/{uid}/cart/{item}      saved cart rows      -> productId
///   users/{uid}/wishlist/{pid}   saved products       -> productId
///   products/{pid}               catalogue, stock, flash-sale percent
///   orders/{oid}                 placed orders        -> userId, items[productId]
class Db {
  static final FirebaseFirestore fs = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get products => fs.collection('products');
  static CollectionReference<Map<String, dynamic>> get orders => fs.collection('orders');
  static CollectionReference<Map<String, dynamic>> userCol(String uid, String name) =>
      fs.collection('users').doc(uid).collection(name);

  static void startUserListeners(String uid) {
    CartManager.start(uid);
    WishlistManager.start(uid);
  }

  static void stopUserListeners() {
    CartManager.stop();
    WishlistManager.stop();
  }

  // ------------------------------------------------------------------ errors
  static String errorText(Object e) {
    if (e is TimeoutException) {
      return 'No connection to the database. Check your internet and try again.';
    }
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
        case 'deadline-exceeded':
          return 'No connection to the database. Check your internet and try again.';
        case 'permission-denied':
          return 'You do not have permission to do that.';
        case 'not-found':
          return 'That record no longer exists.';
      }
      return e.message ?? 'Database error (${e.code}).';
    }
    if (e is StateError) return e.message;
    return 'Something went wrong. Please try again.';
  }

  // ---------------------------------------------------------------- products
  static List<String> keywordsFor(String name, String category) {
    final words = '$name $category'
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toSet();
    final out = <String>{};
    for (final w in words) {
      for (var i = 1; i <= w.length; i++) {
        out.add(w.substring(0, i));
      }
    }
    return out.toList();
  }

  static Map<String, dynamic> productData({
    required String name, required String category, required double price,
    required int stock, required String image, required List<String> images,
    required List<String> colors, required List<String> sizes,
    required String description, required int flashPercent,
  }) =>
      {
        'name': name,
        'nameLower': name.toLowerCase(),
        'category': category,
        'price': price,
        'stock': stock,
        'image': image,
        'images': images,
        'colors': colors,
        'sizes': sizes,
        'description': description,
        'flashPercent': flashPercent,
        'keywords': keywordsFor(name, category),
      };

  /// Live product query. Search uses an indexed prefix-keyword array; the
  /// category filter is a Firestore equality query.
  static Stream<List<Product>> productStream({
    String? category, String search = '', bool flashOnly = false,
  }) {
    Query<Map<String, dynamic>> q = products;
    final term = search.trim().toLowerCase();
    final firstWord = term.split(RegExp(r'\s+')).first;
    if (term.isNotEmpty) {
      q = q.where('keywords', arrayContains: firstWord);
    } else if (category != null) {
      q = q.where('category', isEqualTo: category);
    }
    if (flashOnly) q = q.where('flashPercent', isGreaterThan: 0);
    return q.snapshots().map((snap) {
      var list = snap.docs.map(Product.fromDoc).toList();
      if (term.contains(' ')) {
        list = list.where((p) => p.name.toLowerCase().contains(term)).toList();
      }
      if (term.isNotEmpty && category != null) {
        list = list.where((p) => p.category == category).toList();
      }
      return list;
    });
  }

  static Stream<List<Product>> flashStream() => productStream(flashOnly: true)
      .map((l) => (l.map((p) => p.flashed).toList()..sort((a, b) => a.id.compareTo(b.id))));

  static List<Product> sortProducts(List<Product> list, SortOption sort) {
    final out = List<Product>.from(list);
    switch (sort) {
      case SortOption.relevance:
        out.sort((a, b) => a.id.compareTo(b.id));
      case SortOption.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.nameAZ:
        out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return out;
  }

  static Future<void> saveProduct(Map<String, dynamic> data, {String? id}) async {
    if (id == null) {
      await products.add({...data, 'createdAt': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 15));
    } else {
      await products.doc(id).update(data).timeout(const Duration(seconds: 15));
    }
  }

  static Future<void> deleteProduct(String id) =>
      products.doc(id).delete().timeout(const Duration(seconds: 15));

  /// Inserts the sample catalogue when the products collection is empty.
  static Future<int> seedSampleProducts() async {
    final existing = await products.limit(1).get();
    if (existing.docs.isNotEmpty) return 0;
    final seeds = buildSeedProducts();
    var batch = fs.batch();
    for (var i = 0; i < seeds.length; i++) {
      final id = 'p${(i + 1).toString().padLeft(3, '0')}';
      batch.set(products.doc(id), {...seeds[i], 'createdAt': FieldValue.serverTimestamp()});
      if ((i + 1) % 400 == 0) {
        await batch.commit();
        batch = fs.batch();
      }
    }
    await batch.commit();
    return seeds.length;
  }

  // ------------------------------------------------------------------ orders
  static Stream<List<OrderRecord>> userOrders(String uid) =>
      orders.where('userId', isEqualTo: uid).snapshots().map((s) {
        final l = s.docs.map(OrderRecord.fromDoc).toList();
        l.sort((a, b) => b.date.compareTo(a.date));
        return l;
      });

  static Stream<List<OrderRecord>> adminOrders({String? status}) {
    Query<Map<String, dynamic>> q = orders;
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.snapshots().map((s) {
      final l = s.docs.map(OrderRecord.fromDoc).toList();
      l.sort((a, b) => b.date.compareTo(a.date));
      return l;
    });
  }

  /// Saves the order, reduces product stock and empties the cart in ONE
  /// transaction, so either everything is saved or nothing is.
  static Future<OrderRecord> placeOrder({
    required String name, required String phone, required String address,
    required String city, required String payment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    final items = List<CartItem>.from(CartManager.items);
    if (items.isEmpty) throw StateError('Your cart is empty.');

    final need = <String, int>{};
    for (final it in items) {
      need[it.product.id] = (need[it.product.id] ?? 0) + it.quantity;
    }
    final orderRef = orders.doc();
    final record = OrderRecord(
      id: orderRef.id,
      orderNumber: 'DM${DateTime.now().millisecondsSinceEpoch}',
      userId: user.uid,
      customerName: name, phone: phone, address: address, city: city,
      paymentMethod: payment, total: CartManager.subtotal,
      items: items.map((it) => OrderItem(
        productId: it.product.id, productName: it.product.name,
        image: it.product.image, price: it.product.price,
        quantity: it.quantity, color: it.selectedColor, size: it.selectedSize,
      )).toList(),
      date: DateTime.now(),
    );

    await fs.runTransaction((tx) async {
      final stocks = <String, int>{};
      for (final e in need.entries) {
        final snap = await tx.get(products.doc(e.key));
        if (!snap.exists) {
          throw StateError('A product in your cart is no longer available.');
        }
        final stock = (snap.data()!['stock'] as num?)?.toInt() ?? 0;
        if (stock < e.value) {
          throw StateError('Only $stock left of "${snap.data()!['name']}". '
              'Reduce the quantity in your cart.');
        }
        stocks[e.key] = stock;
      }
      for (final e in need.entries) {
        tx.update(products.doc(e.key), {'stock': stocks[e.key]! - e.value});
      }
      tx.set(orderRef, record.toMap());
      for (final it in items) {
        tx.delete(userCol(user.uid, 'cart').doc(it.docId));
      }
    }).timeout(const Duration(seconds: 20));
    return record;
  }

  static Future<void> updateOrderStatus(String id, String status) =>
      orders.doc(id).update({'status': status}).timeout(const Duration(seconds: 15));

  /// Customer cancels a pending order: status changes and stock is returned.
  static Future<void> cancelOrder(OrderRecord o) async {
    final need = <String, int>{};
    for (final it in o.items) {
      need[it.productId] = (need[it.productId] ?? 0) + it.quantity;
    }
    await fs.runTransaction((tx) async {
      final ref = orders.doc(o.id);
      final cur = await tx.get(ref);
      if (!cur.exists || cur.data()!['status'] != 'Pending') {
        throw StateError('Only pending orders can be cancelled.');
      }
      final snaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final e in need.entries) {
        snaps[e.key] = await tx.get(products.doc(e.key));
      }
      for (final e in need.entries) {
        if (snaps[e.key]!.exists) {
          tx.update(products.doc(e.key), {'stock': FieldValue.increment(e.value)});
        }
      }
      tx.update(ref, {'status': 'Cancelled'});
    }).timeout(const Duration(seconds: 20));
  }

  static Future<void> deleteOrder(String id) =>
      orders.doc(id).delete().timeout(const Duration(seconds: 15));

  // --------------------------------------------------------------- summaries
  /// Database-generated customer summary (Firestore count + sum aggregates).
  static Future<Map<String, num>> customerSummary(String uid) async {
    final agg = await orders.where('userId', isEqualTo: uid)
        .aggregate(count(), sum('total')).get();
    return {'orders': agg.count ?? 0, 'value': agg.getSum('total') ?? 0};
  }

  /// Database-generated admin dashboard figures.
  static Future<Map<String, num>> adminSummary() async {
    final out = <String, num>{};
    out['products'] = (await products.count().get()).count ?? 0;
    out['lowStock'] = (await products.where('stock', isLessThan: 5).count().get()).count ?? 0;
    for (final s in orderStatuses) {
      out[s] = (await orders.where('status', isEqualTo: s).count().get()).count ?? 0;
    }
    out['revenue'] = (await orders.where('status', isEqualTo: 'Delivered')
        .aggregate(sum('total')).get()).getSum('total') ?? 0;
    out['orderValue'] = (await orders.aggregate(sum('total')).get()).getSum('total') ?? 0;
    return out;
  }
}
