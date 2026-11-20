import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(const DMartApp());

class DMartApp extends StatelessWidget {
  const DMartApp({super.key});
  static const Color lime = Color(0xFFC6F135);
  static const Color black = Color(0xFF080A07);
  static const Color panel = Color(0xFF171A15);
  static const Color muted = Color(0xFF252A21);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'D-Mart', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      colorScheme: const ColorScheme.dark(
        primary: lime, secondary: lime, surface: panel,
        onPrimary: black, onSecondary: black, onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: black, foregroundColor: Colors.white,
        elevation: 0, centerTitle: false),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: panel, indicatorColor: lime,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: lime,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: muted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: lime, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: lime, foregroundColor: black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18))),
      cardTheme: CardThemeData(color: panel, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: muted))),
      textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      dividerColor: muted,
    ),
    home: const HomeScreen(),
  );
}
