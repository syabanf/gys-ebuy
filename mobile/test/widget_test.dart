import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gys_buyer_prototype/app/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const GysBuyerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    // Drain the splash screen's auto-navigate timer so the test doesn't
    // fail on pending timers.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
