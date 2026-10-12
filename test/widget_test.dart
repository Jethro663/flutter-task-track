import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/main.dart';

void main() {
  testWidgets('TaskTrack home loads with user-driven empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TaskTrack'), findsOneWidget);
    expect(find.text('TaskTrack User'), findsOneWidget);
    expect(find.text('No pending tasks.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
  });
}
