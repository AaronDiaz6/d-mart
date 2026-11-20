/// Form validators shared by login, checkout, profile and admin forms.
class Validators {
  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? phone(String? v, {bool requiredField = false}) {
    final t = (v ?? '').replaceAll(' ', '');
    if (t.isEmpty) return requiredField ? 'Phone number is required' : null;
    return RegExp(r'^(\+256|0)\d{9}$').hasMatch(t)
        ? null
        : 'Enter a valid number, e.g. 0772 123 456';
  }

  static String? price(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null) return 'Enter a valid price';
    if (n <= 0) return 'Price must be greater than 0';
    if (n > 100000000) return 'Price is too large';
    return null;
  }

  static String? stock(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Enter a whole number';
    if (n < 0) return 'Stock cannot be negative';
    if (n > 100000) return 'Stock is too large';
    return null;
  }

  static String? percent(String? v) {
    if (v == null || v.trim().isEmpty) return null; // empty = no flash sale
    final n = int.tryParse(v.trim());
    if (n == null || n < 0 || n > 90) return 'Enter a whole number from 0 to 90';
    return null;
  }

  static String? imageUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'Image URL is required';
    final t = v.trim();
    return (t.startsWith('http://') || t.startsWith('https://'))
        ? null
        : 'Enter a valid link starting with http';
  }
}
