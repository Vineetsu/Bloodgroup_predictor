import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_group_predictor/main.dart';

void main() {
  testWidgets('Blood Group Predictor UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodGroupPredictorApp());

    expect(find.text("Blood Group Predictor"), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A+').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('B+').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Predict"));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsWidgets);
  });
}
