import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'auth_service.dart';
import 'home_screen.dart';
import 'main.dart';
import 'splash_screen.dart';
import 'validators.dart';

/// Customers open the shopping app; admins open the admin panel.
Widget homeFor(UserProfile profile) =>
    profile.isAdmin ? const AdminHomeScreen() : const HomeScreen();

/// Confirm, sign out and return to the login screen (used by customer and admin).
Future<void> confirmAndLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to continue shopping.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LOG OUT')),
      ],
    ),
  );
  if (ok != true) return;
  await AuthService.signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final profile = await AuthService.signIn(_email.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeFor(profile)), (route) => false);
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final problem = Validators.email(_email.text);
    if (problem != null) {
      setState(() => _error = 'Enter your email above first, then tap "Forgot password?"');
      return;
    }
    try {
      await AuthService.sendPasswordReset(_email.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent. Check your email.')));
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Center(child: DMartLogo(size: 76, glow: 22)),
                  const SizedBox(height: 22),
                  const Text('Welcome back', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Sign in to continue shopping', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _email, keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password, obscureText: _hide,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _hide = !_hide)),
                    ),
                  ),
                  Align(alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _forgot, child: const Text('Forgot password?'))),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.12), borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(.5))),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                      ]),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : _login,
                    child: _busy
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: DMartApp.black))
                        : const Text('SIGN IN'),
                  ),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('New to D-Mart?', style: TextStyle(color: Colors.white60)),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Create account')),
                  ]),
                  const SizedBox(height: 6),
                  const Text('Store staff: sign in with your admin account to open the admin panel.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ),
            ),
          ),
        ),
      );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final profile = await AuthService.register(
        name: _name.text, email: _email.text, password: _password.text, phone: _phone.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => homeFor(profile)), (route) => false);
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(
                  controller: _name, textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, 'Full name'),
                  decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email, keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone, keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v),
                  decoration: const InputDecoration(labelText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_outlined))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password, obscureText: _hide, validator: Validators.password,
                  decoration: InputDecoration(
                    labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _hide = !_hide)))),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm, obscureText: _hide,
                  validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                  decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 18),
                if (_error != null)
                  Padding(padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
                FilledButton(
                  onPressed: _busy ? null : _register,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: DMartApp.black))
                      : const Text('CREATE ACCOUNT')),
              ]),
            ),
          ),
        ),
      );
}
