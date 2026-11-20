import 'package:flutter/material.dart';
import 'db_service.dart';
import 'main.dart';
import 'product.dart';
import 'product_grid.dart';
import 'product_image.dart';
import 'products.dart';
import 'validators.dart';

/// Admin: create, read, update and delete products in Firestore.
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _search = '';
  String? _category;
  SortOption _sort = SortOption.relevance;
  late Stream<List<Product>> _stream = Db.productStream();

  void _reload() => setState(() => _stream = Db.productStream(search: _search, category: _category));

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${p.name}" will be permanently removed from the store.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
        ],
      ),
    );
    if (ok != true) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Db.deleteProduct(p.id);
      messenger.showSnackBar(SnackBar(content: Text('"${p.name}" deleted')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
    }
  }

  void _openForm([Product? p]) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)));

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openForm,
          backgroundColor: DMartApp.lime, foregroundColor: DMartApp.black,
          icon: const Icon(Icons.add), label: const Text('Add product')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(children: [
              Expanded(child: TextField(
                onChanged: (v) { _search = v; _reload(); },
                decoration: const InputDecoration(hintText: 'Search products', prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.zero))),
              PopupMenuButton<SortOption>(
                tooltip: 'Sort', icon: const Icon(Icons.sort_rounded, color: DMartApp.lime),
                initialValue: _sort, onSelected: (s) => setState(() => _sort = s),
                itemBuilder: (_) => [for (final s in SortOption.values) PopupMenuItem(value: s, child: Text(s.label))]),
            ]),
          ),
          SizedBox(height: 42, child: ListView(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              for (final c in [null, ...categories])
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ChoiceChip(
                  label: Text(c ?? 'All'), selected: _category == c,
                  selectedColor: DMartApp.lime,
                  labelStyle: TextStyle(color: _category == c ? DMartApp.black : Colors.white, fontWeight: FontWeight.w700),
                  onSelected: (_) { _category = c; _reload(); })),
            ],
          )),
          Expanded(child: StreamBuilder<List<Product>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return StateMessage(icon: Icons.cloud_off_rounded, text: Db.errorText(snap.error!));
              }
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: DMartApp.lime));
              final list = Db.sortProducts(snap.data!, _sort);
              if (list.isEmpty) {
                return const StateMessage(icon: Icons.inventory_2_outlined, text: 'No products match. Tap "Add product" to create one.');
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: ProductImage(url: p.image, label: p.name, category: p.category, width: 52, height: 52)),
                    title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${p.category} • UGX ${p.price.toStringAsFixed(0)}\n'
                      'Stock: ${p.stock}${p.flashPercent > 0 ? ' • Flash -${p.flashPercent}%' : ''}',
                      style: TextStyle(color: p.stock < 5 ? Colors.orangeAccent : Colors.white60, fontSize: 12)),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => v == 'edit' ? _openForm(p) : _delete(p),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ]),
                    onTap: () => _openForm(p),
                  ));
                },
              );
            },
          )),
        ]),
      );
}

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = create
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _price = TextEditingController(text: widget.product == null ? '' : widget.product!.price.toStringAsFixed(0));
  late final _stock = TextEditingController(text: widget.product?.stock.toString());
  late final _image = TextEditingController(text: widget.product?.image);
  late final _flash = TextEditingController(text: (widget.product?.flashPercent ?? 0).toString());
  late final _colors = TextEditingController(text: widget.product?.colors.join(', '));
  late final _sizes = TextEditingController(text: widget.product?.sizes.join(', '));
  late final _desc = TextEditingController(text: widget.product?.description);
  late String _category = widget.product?.category ?? categories.first;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _price, _stock, _image, _flash, _colors, _sizes, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _split(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final image = _image.text.trim();
    final old = widget.product;
    final images = (old != null && old.image == image && old.images.isNotEmpty) ? old.images : [image];
    try {
      await Db.saveProduct(
        Db.productData(
          name: _name.text.trim(), category: _category,
          price: double.parse(_price.text.trim()), stock: int.parse(_stock.text.trim()),
          image: image, images: images, colors: _split(_colors.text), sizes: _split(_sizes.text),
          description: _desc.text.trim().isEmpty ? 'A quality product from D-Mart.' : _desc.text.trim(),
          flashPercent: int.tryParse(_flash.text.trim()) ?? 0),
        id: old?.id);
      messenger.showSnackBar(SnackBar(content: Text(old == null ? 'Product added' : 'Product updated')));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(Db.errorText(e))));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.product == null ? 'Add product' : 'Edit product')),
        body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(18), children: [
          TextFormField(controller: _name, validator: (v) {
              final r = Validators.required(v, 'Product name');
              if (r != null) return r;
              return v!.trim().length < 3 ? 'Name is too short' : null;
            },
            decoration: const InputDecoration(labelText: 'Product name')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category')),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextFormField(controller: _price, keyboardType: TextInputType.number,
              validator: Validators.price, decoration: const InputDecoration(labelText: 'Price (UGX)'))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _stock, keyboardType: TextInputType.number,
              validator: Validators.stock, decoration: const InputDecoration(labelText: 'Stock'))),
          ]),
          const SizedBox(height: 14),
          TextFormField(controller: _image, keyboardType: TextInputType.url, validator: Validators.imageUrl,
            decoration: const InputDecoration(labelText: 'Image URL')),
          const SizedBox(height: 14),
          TextFormField(controller: _flash, keyboardType: TextInputType.number, validator: Validators.percent,
            decoration: const InputDecoration(labelText: 'Flash sale discount % (0 = none)')),
          const SizedBox(height: 14),
          TextFormField(controller: _colors,
            decoration: const InputDecoration(labelText: 'Colours (comma separated, optional)')),
          const SizedBox(height: 14),
          TextFormField(controller: _sizes,
            decoration: const InputDecoration(labelText: 'Sizes (comma separated, optional)')),
          const SizedBox(height: 14),
          TextFormField(controller: _desc, maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description (optional)')),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: DMartApp.black))
                : Text(widget.product == null ? 'ADD PRODUCT' : 'SAVE CHANGES')),
        ])),
      );
}
