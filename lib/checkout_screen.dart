import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  String paymentMethod = 'Cash on Delivery';
  bool placingOrder = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  String? requiredField(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          const Text('Delivery information', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _field(nameController, 'Full name', Icons.person, validator: requiredField),
          _field(phoneController, 'Phone number', Icons.phone, keyboard: TextInputType.phone, validator: requiredField),
          _field(addressController, 'Delivery address', Icons.location_on, validator: requiredField),
          _field(cityController, 'Town / City', Icons.location_city, validator: requiredField),
          const SizedBox(height: 20),
          const Text('Payment method', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            value: 'Cash on Delivery', groupValue: paymentMethod,
            title: const Text('Cash on Delivery'),
            onChanged: (v) => setState(() => paymentMethod = v!)),
          RadioListTile<String>(
            value: 'Mobile Money (Simulation)', groupValue: paymentMethod,
            title: const Text('Mobile Money (Simulation)'),
            subtitle: const Text('Demo only — no real payment is processed.'),
            onChanged: (v) => setState(() => paymentMethod = v!)),
          const Divider(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Order total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('UGX ${CartManager.subtotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: placingOrder ? null : _placeOrder,
            child: placingOrder
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Place order'),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xFF171A15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (CartManager.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }
    setState(() => placingOrder = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final orderItems = CartManager.items.map((item) => OrderItem(
      productName: item.product.name, image: item.product.image,
      price: item.product.price, quantity: item.quantity,
      color: item.selectedColor, size: item.selectedSize,
    )).toList();
    final order = OrderRecord(
      customerName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      paymentMethod: paymentMethod,
      total: CartManager.subtotal,
      items: orderItems,
    );
    OrderHistory.add(order);
    CartManager.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => OrderConfirmationScreen(order: order)));
  }
}
