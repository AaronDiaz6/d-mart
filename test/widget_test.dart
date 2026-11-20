import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:d_mart/main.dart';

void main() {
  testWidgets('D-Mart app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const DMartApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}