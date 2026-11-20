import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'db_service.dart';

class UserProfile {
  final String uid, name, email, phone, address, photoUrl, role;
  const UserProfile({
    required this.uid, required this.name, required this.email,
    required this.phone, required this.address, required this.photoUrl,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(String uid, Map<String, dynamic> d) => UserProfile(
    uid: uid,
    name: (d['name'] ?? '').toString(),
    email: (d['email'] ?? '').toString(),
    phone: (d['phone'] ?? '').toString(),
    address: (d['address'] ?? '').toString(),
    photoUrl: (d['photoUrl'] ?? '').toString(),
    role: (d['role'] ?? 'customer').toString(),
  );
}

/// Firebase Authentication + the users/{uid} profile document.
/// Two user types: "customer" (default) and "admin" (the admin email below).
class AuthService {
  static const String adminEmail = 'admin@dmart.com';
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static UserProfile? current;

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  static Future<UserProfile> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    return loadProfile(cred.user!);
  }

  static Future<UserProfile> register({
    required String name, required String email,
    required String password, String phone = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user!.updateDisplayName(name.trim());
    return loadProfile(cred.user!, name: name.trim(), phone: phone.trim());
  }

  /// Loads (or creates) the profile document and starts the cart/wishlist
  /// listeners for customers.
  static Future<UserProfile> loadProfile(User user, {String? name, String phone = ''}) async {
    final ref = userDoc(user.uid);
    var snap = await ref.get();
    if (!snap.exists) {
      final email = (user.email ?? '').toLowerCase();
      await ref.set({
        'name': name ?? user.displayName ?? email.split('@').first,
        'email': email,
        'phone': phone,
        'address': '',
        'photoUrl': '',
        'role': email == adminEmail ? 'admin' : 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      snap = await ref.get();
    }
    final profile = UserProfile.fromMap(user.uid, snap.data()!);
    current = profile;
    if (!profile.isAdmin) Db.startUserListeners(user.uid);
    return profile;
  }

  static Stream<UserProfile?> profileStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return userDoc(user.uid).snapshots().map((s) {
      if (!s.exists) return null;
      final p = UserProfile.fromMap(user.uid, s.data()!);
      current = p;
      return p;
    });
  }

  static Future<void> updateProfile(Map<String, dynamic> data) {
    final user = _auth.currentUser;
    if (user == null) return Future.error(StateError('Please sign in again.'));
    return userDoc(user.uid).update(data).timeout(const Duration(seconds: 15));
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static Future<void> signOut() async {
    Db.stopUserListeners();
    current = null;
    await _auth.signOut();
  }

  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'network-request-failed':
          return 'No internet connection. Check your network and try again.';
      }
      return e.message ?? 'Sign-in failed (${e.code}).';
    }
    return Db.errorText(e);
  }
}
