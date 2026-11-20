class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String image;
  final List<String> images;
  final List<String> colors;
  final List<String> sizes;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.oldPrice,
    this.images = const [],
    this.colors = const [],
    this.sizes = const [],
    this.description = 'A quality product selected for everyday use.',
  });

  bool get onSale => oldPrice != null;

  int get discountPercent =>
      oldPrice == null ? 0 : (((oldPrice! - price) / oldPrice!) * 100).round();

  /// Same product at a flash-sale price (rounded to the nearest UGX 500).
  Product withDiscount(int percent) {
    final sale = ((price * (100 - percent) / 100) / 500).round() * 500.0;
    return Product(
      id: id, name: name, category: category, price: sale, oldPrice: price,
      image: image, images: images, colors: colors, sizes: sizes,
      description: description,
    );
  }
}

class WishlistManager {
  static final List<Product> items = [];

  static bool contains(Product product) =>
      items.any((item) => item.id == product.id);

  static void add(Product product) {
    if (!contains(product)) items.add(product);
  }

  static void remove(Product product) {
    items.removeWhere((item) => item.id == product.id);
  }

  static void toggle(Product product) {
    contains(product) ? remove(product) : add(product);
  }
}
