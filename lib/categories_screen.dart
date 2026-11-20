import 'package:flutter/material.dart';
import 'main.dart';
import 'products.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explore categories')),
    body: GridView.builder(
      padding: const EdgeInsets.all(14), itemCount: categoryInfo.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .82),
      itemBuilder: (context, index) {
        final info = categoryInfo[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: info.name))),
          child: Ink(
            decoration: BoxDecoration(color: DMartApp.panel, borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(fit: StackFit.expand, children: [
              Image.network(info.coverUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: DMartApp.panel,
                  child: Icon(info.icon, size: 46, color: DMartApp.lime))),
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(.85)]))),
              Positioned(left: 14, right: 12, bottom: 14, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(info.name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(info.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 7),
                  const Row(children: [
                    Text('SHOP NOW', style: TextStyle(color: DMartApp.lime, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: DMartApp.lime, size: 15)]),
                ])),
            ])),
          ),
        );
      },
    ),
  );
}
