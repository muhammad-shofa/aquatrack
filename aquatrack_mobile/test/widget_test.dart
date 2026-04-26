import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders basic material app shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('AQUATRACK'))),
    );

    expect(find.text('AQUATRACK'), findsOneWidget);
  });
}
