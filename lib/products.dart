import 'package:flutter/material.dart';
import 'product.dart';

// ---------------------------------------------------------------------------
// CATEGORIES
// ---------------------------------------------------------------------------
class CategoryInfo {
  final String name;
  final String description;
  final IconData icon;
  final String cover; // Unsplash photo id (without the "photo-" prefix)
  const CategoryInfo(this.name, this.description, this.icon, this.cover);
  String get coverUrl => _img(cover, 900);
}

const List<CategoryInfo> categoryInfo = [
  CategoryInfo('Fashion', 'Clothing and everyday style', Icons.checkroom_rounded, '1551028719-00167b16eac5'),
  CategoryInfo('Electronics', 'Smart devices and gadgets', Icons.headphones_rounded, '1505740420928-5e560c06d30e'),
  CategoryInfo('Phones & PCs', 'Phones, laptops and tablets', Icons.smartphone_rounded, '1511707171634-5f897ff02aa9'),
  CategoryInfo('Shoes', 'Footwear for every occasion', Icons.directions_walk_rounded, '1542291026-7eec264c27ff'),
  CategoryInfo('Beauty', 'Personal care and makeup', Icons.brush_rounded, '1596462502278-27bfdc403348'),
  CategoryInfo('Home', 'Decor and comfort for your space', Icons.chair_rounded, '1584100936595-c0654b55a2e2'),
  CategoryInfo('Kitchen', 'Cookware, appliances and dining', Icons.kitchen_rounded, '1556911220-e15b29be8c8f'),
  CategoryInfo('Accessories', 'Finishing touches and essentials', Icons.watch_rounded, '1553062407-98eeb64c6a62'),
  CategoryInfo('Sports', 'Gear for training and play', Icons.sports_soccer_rounded, '1579952363873-27f3bade9f55'),
];

final List<String> categories = categoryInfo.map((c) => c.name).toList();
final List<String> categoryDescriptions = categoryInfo.map((c) => c.description).toList();

IconData categoryIcon(String category) =>
    categoryInfo.firstWhere((c) => c.name == category, orElse: () => categoryInfo.first).icon;

// ---------------------------------------------------------------------------
// IMAGES
// Every product has its OWN photo id. The gallery is the same photo shown
// three ways (full view + two close-ups), so swiping always shows the SAME
// product. Lines marked  // ?  are the ones to double-check first.
// ---------------------------------------------------------------------------
String _img(String id, int size) =>
    'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=$size&h=$size&q=85';

String _zoom(String id, double x, double y) =>
    'https://images.unsplash.com/photo-$id?auto=format&fit=crop&crop=focalpoint&w=900&h=900&fp-x=$x&fp-y=$y&fp-z=1.8&q=85';

typedef _Seed = (String name, int price, String photo);

const List<_Seed> _fashion = [
  ('Classic T-Shirt', 25000, '1521572163474-6864f9cf17ab'),
  ('Casual Shirt', 45000, '1598033129183-c4f50c736f10'),
  ('Denim Jacket', 120000, '1551028719-00167b16eac5'),
  ('Slim Fit Jeans', 85000, '1542272604-787c3835535d'),
  ('Cotton Hoodie', 95000, '1556821840-3a63f95609a7'),
  ('Summer Dress', 75000, '1595777457583-95e059d581b8'),
  ('Polo Shirt', 40000, '1625910513413-5fc45e6f4f9b'), // ?
  ('Formal Trousers', 70000, '1594633312681-425c7b97ccd1'), // ?
  ('Sports Shorts', 30000, '1562183241-b937e95585b6'), // ?
  ('Winter Sweater', 80000, '1576566588028-4147f3842f27'),
  ('Casual Skirt', 50000, '1583496661160-fb5886a0aaaa'), // ?
  ('Track Suit', 110000, '1556906781-9a412961c28c'), // ?
  ('Lightweight Jacket', 105000, '1544923246-77307dd654cb'),
  ('Chino Pants', 65000, '1473966968600-fa801b869a1a'),
  ('Linen Shirt', 55000, '1596755094514-f87e34085b2c'),
  ('Long Sleeve Top', 38000, '1551488831-00ddcb6c6bd3'), // ?
  ('Suit Blazer', 150000, '1507679799987-c73779587ccf'),
];

const List<_Seed> _electronics = [
  ('Wireless Headphones', 120000, '1505740420928-5e560c06d30e'),
  ('Bluetooth Speaker', 90000, '1608043152269-423dbba4e7e1'),
  ('Smart Watch', 180000, '1523275335684-37898b6baf30'),
  ('Power Bank', 55000, '1609592806596-b43bada2f6a1'), // ?
  ('USB-C Charger', 35000, '1583863788434-e58a36330cf0'), // ?
  ('Wireless Mouse', 40000, '1527814050087-3793815479db'),
  ('Mechanical Keyboard', 150000, '1587829741301-dc798b83add3'),
  ('Phone Stand', 20000, '1512499617640-c74ae3a79d37'), // ?
  ('Portable SSD', 260000, '1597872200969-2b65d56bd16b'), // ?
  ('Webcam', 95000, '1587826080692-f439cd0b70da'), // ?
  ('Digital Camera', 850000, '1516035069371-29a1b244cc32'),
  ('Smart TV', 1200000, '1593359677879-a4bb92f829d1'),
  ('Gaming Controller', 130000, '1592840496694-26d035b52b48'),
  ('Earbuds', 85000, '1606220945770-b5b6c2c55bf1'),
  ('Fitness Band', 75000, '1575311373937-040b8e1fd5b6'),
  ('Computer Monitor', 650000, '1527443224154-c4a3942d3acf'),
  ('Camera Drone', 1500000, '1473968512647-3e447244af8f'),
];

const List<_Seed> _phones = [
  ('Smartphone', 1100000, '1511707171634-5f897ff02aa9'),
  ('Android Phone', 780000, '1598327105666-5b89351aff97'),
  ('Business Laptop', 2200000, '1496181133206-80ce9b88a853'),
  ('Gaming Laptop', 3400000, '1603302576837-37561b2e2302'),
  ('Slim Notebook', 1900000, '1593642632823-8f785ba67e45'),
  ('Tablet', 900000, '1544244015-0df4b3ffc6b0'),
  ('Phone Case', 25000, '1601784551446-20c9e07cdbdb'),
  ('Office Printer', 520000, '1612815154858-60aa4c59eaa6'),
];

const List<_Seed> _shoes = [
  ('Running Sneakers', 150000, '1542291026-7eec264c27ff'),
  ('Casual Sneakers', 120000, '1514989940723-e8e51635b782'),
  ('Leather Loafers', 140000, '1614252369475-531eba835eb1'),
  ('Walking Shoes', 110000, '1460353581641-37baddab0fa2'),
  ('Canvas Shoes', 70000, '1525966222134-fcfa99b8ae77'),
  ('Training Shoes', 130000, '1600185365483-26d7a4cc7519'),
  ('Trail Shoes', 160000, '1551632811-561732d1e306'), // ?
  ('Ladies Flat Shoes', 85000, '1543163521-1bf539c55dd2'), // ?
  ('Formal Oxford Shoes', 175000, '1533867617858-e7b97e060509'),
  ('Ankle Boots', 165000, '1608256246200-53e635b5b65f'),
  ('Everyday Sandals', 45000, '1562273138-f46be4ebdf33'), // ?
  ('White Court Sneakers', 135000, '1549298916-b41d501d3772'), // ?
  ('Basketball Shoes', 190000, '1579338559194-a162d19bf842'), // ?
  ('Slip-On Shoes', 90000, '1560343090-f0409e92791a'),
];

const List<_Seed> _beauty = [
  ('Daily Face Cleanser', 28000, '1608248543803-ba4f8c70ae0b'),
  ('Moisturising Cream', 32000, '1601049541289-9b1b7bbbfe19'),
  ('Body Lotion', 24000, '1611930022073-b7a4ba5fcccd'),
  ('Sunscreen', 38000, '1556229010-6c3f2c9ca5f8'), // ?
  ('Lipstick', 22000, '1586495777744-4413f21062fa'),
  ('Makeup Brush Set', 45000, '1596462502278-27bfdc403348'),
  ('Perfume', 95000, '1541643600914-78b084683601'),
  ('Nail Polish', 12000, '1632345031435-8727f6897d53'),
  ('Face Serum', 52000, '1620916566398-39f1143ab7be'),
  ('Foundation', 42000, '1522335789203-aabd1fc54bc9'),
  ('Eyeshadow Palette', 48000, '1512496015851-a90fb38ba796'),
  ('Makeup Kit', 120000, '1487412947147-5cebf100ffc2'),
];

const List<_Seed> _home = [
  ('Ceramic Mug Set', 35000, '1514228742587-6b1558fcca3d'),
  ('Bed Sheet Set', 85000, '1631049307264-da0ec9d70304'),
  ('Decorative Cushion', 28000, '1584100936595-c0654b55a2e2'),
  ('Storage Basket', 32000, '1593085260707-5377ba37f868'), // ?
  ('Wall Clock', 45000, '1563861826100-9cb868fdbe1c'),
  ('Table Lamp', 60000, '1507473885765-e6ed057f782c'),
  ('Bath Towel', 30000, '1600369671236-e74521d4b6ad'),
  ('Plant Pot', 18000, '1485955900006-10f4d324d411'),
  ('Scented Candle', 22000, '1602874801007-bd458bb1b8b6'),
  ('Ceramic Vase', 38000, '1578500494198-246f612d3b3d'),
  ('Armchair', 420000, '1503602642458-232111445657'),
  ('Wall Mirror', 95000, '1618220179428-22790b461013'), // ?
];

const List<_Seed> _kitchen = [
  ('Kitchen Utensil Set', 40000, '1556911220-e15b29be8c8f'),
  ('Blender', 140000, '1570222094114-d054a817e56b'),
  ('Coffee Maker', 220000, '1517668808822-9ebb02f2a0e6'),
  ('Knife Set', 85000, '1593618998160-e34014e67546'),
  ('Cooking Pot', 65000, '1584990347449-a0a0f0f1d0f4'), // ?
  ('Water Bottle', 25000, '1602143407151-7111542de6e8'),
  ('Food Storage Set', 48000, '1584473457409-ae5c91d7d7a7'), // ?
  ('Toaster', 110000, '1585515320310-259814833e62'),
  ('Dinner Plate Set', 90000, '1603199506016-b9a594b593c0'),
  ('Wine Glasses', 55000, '1510812431401-41d2bd2722f3'),
  ('Tea Set', 75000, '1576092768241-dec231879fc3'),
  ('Wooden Chopping Board', 30000, '1594226801341-41427b4cd5df'), // ?
];

const List<_Seed> _accessories = [
  ('Classic Wrist Watch', 160000, '1523170335258-f5ed11844a49'),
  ('Leather Wallet', 55000, '1627123424574-724758594e93'),
  ('Crossbody Bag', 90000, '1584917865442-de89df76afd3'),
  ('Backpack', 80000, '1553062407-98eeb64c6a62'),
  ('Sunglasses', 50000, '1511499767150-a48a237f0083'),
  ('Baseball Cap', 25000, '1588850561407-ed78c282e89b'),
  ('Leather Belt', 40000, '1624222247344-550fb8d4b5f7'), // ?
  ('Scarf', 28000, '1601924994987-69e26d50dc26'), // ?
  ('Minimal Necklace', 35000, '1599643478518-a784e5dc4c8f'),
  ('Bracelet Set', 30000, '1611652022419-a9419f74343d'),
  ('Umbrella', 25000, '1534274988757-a28bf1a57c17'), // ?
  ('Travel Suitcase', 230000, '1565026057447-bc90a3dceb87'), // ?
  ('Gold Ring', 65000, '1605100804763-247f67b3557e'),
  ('Drop Earrings', 32000, '1535632066927-ab7c9ab60908'),
  ('Fedora Hat', 45000, '1514327605112-b887c0e61c0a'),
];

const List<_Seed> _sports = [
  ('Football', 60000, '1579952363873-27f3bade9f55'),
  ('Basketball', 70000, '1546519638-68e109498ffc'),
  ('Dumbbell Set', 120000, '1583454110551-21f2fa2afe61'),
  ('Yoga Mat', 45000, '1601925260368-ae2f83cf8b7f'), // ?
  ('Tennis Racket', 130000, '1595435934249-5df7ed86e1c0'),
  ('Boxing Gloves', 85000, '1549719386-74dfcbf7dbed'),
  ('Mountain Bicycle', 850000, '1485965120184-e220f721d03e'),
  ('Skipping Rope', 15000, '1598289431512-b97b0917affc'), // ?
  ('Kettlebell', 95000, '1517344884509-a0c97ec11bcc'), // ?
  ('Volleyball', 55000, '1612872087720-bb876e2e67d1'),
];

// ---------------------------------------------------------------------------
// BUILDING THE CATALOGUE
// ---------------------------------------------------------------------------
List<Product> _make(List<_Seed> seeds, String category, int startId,
    {List<String> colors = const [], List<String> sizes = const []}) {
  return List.generate(seeds.length, (i) {
    final (name, price, photo) = seeds[i];
    return Product(
      id: startId + i,
      name: name,
      category: category,
      price: price.toDouble(),
      image: _img(photo, 900),
      images: [_img(photo, 900), _zoom(photo, .5, .5), _zoom(photo, .3, .65)],
      colors: colors,
      sizes: sizes,
      description:
          '$name from D-Mart. A practical choice with a clean design and great everyday value.',
    );
  });
}

const _clothingColors = ['Black', 'White', 'Navy', 'Olive'];
const _shoeColors = ['Black', 'White', 'Brown'];
const _techColors = ['Black', 'Silver', 'White'];

final List<Product> products = [
  ..._make(_fashion, 'Fashion', 1, colors: _clothingColors, sizes: ['S', 'M', 'L', 'XL', 'XXL']),
  ..._make(_electronics, 'Electronics', 101, colors: _techColors),
  ..._make(_phones, 'Phones & PCs', 151, colors: _techColors),
  ..._make(_shoes, 'Shoes', 201, colors: _shoeColors, sizes: ['39', '40', '41', '42', '43', '44', '45']),
  ..._make(_beauty, 'Beauty', 301),
  ..._make(_home, 'Home', 401),
  ..._make(_kitchen, 'Kitchen', 451),
  ..._make(_accessories, 'Accessories', 501, colors: ['Black', 'Brown', 'Gold']),
  ..._make(_sports, 'Sports', 601),
];

/// Products shown on the home page "Picked for you" grid (a mix of every category).
final List<Product> featuredProducts = [
  for (var i = 0; i < products.length; i++)
    if (i % 5 == 0) products[i],
];

// ---------------------------------------------------------------------------
// FLASH SALES  (product name -> discount %)
// ---------------------------------------------------------------------------
const Map<String, int> _flashDeals = {
  'Wireless Headphones': 30,
  'Running Sneakers': 25,
  'Smart Watch': 35,
  'Denim Jacket': 20,
  'Blender': 30,
  'Smartphone': 15,
  'Perfume': 40,
  'Backpack': 25,
  'Football': 30,
  'Bluetooth Speaker': 35,
  'Coffee Maker': 20,
  'Bed Sheet Set': 30,
};

final List<Product> flashSales = [
  for (final e in _flashDeals.entries)
    products.firstWhere((p) => p.name == e.key).withDiscount(e.value),
];

/// Flash sales reset every 6 hours (00:00, 06:00, 12:00, 18:00).
Duration flashTimeLeft() {
  final now = DateTime.now();
  final next = DateTime(now.year, now.month, now.day, (now.hour ~/ 6 + 1) * 6);
  return next.difference(now);
}
