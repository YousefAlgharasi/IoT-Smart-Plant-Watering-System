import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_plant_watering/main.dart';

void main() {
  testWidgets('Dashboard responsive layout test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartPlantApp());

    expect(find.text('Smart Plant Dashboard'), findsOneWidget);
    expect(find.byType(LayoutBuilder), findsWidgets);
  });
}
