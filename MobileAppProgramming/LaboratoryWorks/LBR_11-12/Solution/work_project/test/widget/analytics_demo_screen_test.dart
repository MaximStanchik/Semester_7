import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:work_project/screens/analytics_demo_screen.dart';

void main() {
  testWidgets('AnalyticsDemoScreen tap demo event shows status card', (tester) async {
    print('[widget] START: AnalyticsDemoScreen tap demo event shows status card');
    await tester.pumpWidget(
      const MaterialApp(
        home: AnalyticsDemoScreen(),
      ),
    );

    await tester.pumpAndSettle();

    print('[widget] Tap: demo_screen_open');
    await tester.tap(find.text('demo_screen_open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Отправлено событие: demo_screen_open'), findsOneWidget);
    print('[widget] PASSED: AnalyticsDemoScreen tap demo event shows status card');
  });
}
