# D-Mart: Firebase setup (one time, about 10 minutes)

1. **Create the project**: console.firebase.google.com > Add project (e.g. `dmart`).
2. **Authentication**: Build > Authentication > Get started > enable **Email/Password**.
3. **Database**: Build > Firestore Database > Create database (start in production mode, pick a region).
4. **Security rules**: Firestore > Rules tab > paste everything from `firestore.rules` > Publish.
5. **Connect the app** (in your project folder):
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   flutter pub get
   ```
   This overwrites `lib/firebase_options.dart` and adds `google-services.json`.
   Android only: make sure `minSdkVersion` is at least 23 in `android/app/build.gradle`.
6. **Admin account**: run the app, tap *Create account* and register with **admin@dmart.com**.
   Signing in as that email opens the admin panel and loads the 117 sample products automatically.
   Every other email registers as a **customer**.
7. Sign out, register a customer, and shop. Orders appear in the admin panel.

## Collections
| Path | Purpose |
|---|---|
| `users/{uid}` | profile and role (`customer` or `admin`) |
| `users/{uid}/cart/{item}` | cart rows (link to `products`) |
| `users/{uid}/wishlist/{productId}` | saved products |
| `products/{productId}` | catalogue, stock, flash-sale percent |
| `orders/{orderId}` | orders (link to `users` by `userId`, to `products` by `items[].productId`) |
