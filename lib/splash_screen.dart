import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'main.dart';

/// Lime app logo with a soft glow (reused on the splash and login screens).
class DMartLogo extends StatelessWidget {
  final double size;
  final double glow;
  const DMartLogo({super.key, this.size = 96, this.glow = 28});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: DMartApp.lime,
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: [BoxShadow(color: DMartApp.lime.withOpacity(.45), blurRadius: glow, spreadRadius: 2)],
        ),
        child: Icon(Icons.shopping_bag_rounded, color: DMartApp.black, size: size * .54),
      );
}

/// Shown every time the app opens. Checks whether someone is already signed
/// in, then opens the right home screen (customer or admin) or the login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final minimumShow = Future.delayed(const Duration(milliseconds: 2800));
    Widget next = const LoginScreen();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await AuthService.loadProfile(user).timeout(const Duration(seconds: 8));
        next = homeFor(profile);
      }
    } catch (_) {
      next = const LoginScreen();
    }
    await minimumShow;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => next,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _intro, curve: Curves.elasticOut);
    final fade = CurvedAnimation(parent: _intro, curve: const Interval(.3, 1, curve: Curves.easeOut));
    return Scaffold(
      backgroundColor: DMartApp.black,
      body: SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),
          ScaleTransition(
            scale: scale,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => DMartLogo(size: 110, glow: 22 + 22 * _pulse.value),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: fade,
            child: Column(children: const [
              Text('D-MART', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 5)),
              SizedBox(height: 8),
              Text('EVERYDAY FINDS, DELIVERED',
                style: TextStyle(color: DMartApp.lime, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.4)),
            ]),
          ),
          const Spacer(flex: 3),
          FadeTransition(
            opacity: fade,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 40),
              child: Column(children: [
                ClipRRect(borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(minHeight: 4, color: DMartApp.lime, backgroundColor: DMartApp.muted)),
                const SizedBox(height: 10),
                const Text('Getting your store ready…', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
