// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:craigslist_flutter_app/features/product/presentation/pages/product_listing_page.dart';

void main() {
  testWidgets('Product listing page smoke test', (WidgetTester tester) async {
    // Build a test widget
    await tester.pumpWidget(const MaterialApp(
      home: ProductListingPage(),
    ));

    // Verify that the page loads without errors
    expect(find.byType(ProductListingPage), findsOneWidget);
  });
}
