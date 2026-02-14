import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laba3/ui/widgets/feedback_form.dart';
import 'package:laba3/main.dart' show PageViewScreen;

void main() {
  Widget buildWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  testWidgets('FeedbackForm submits text and shows result', (tester) async {
    await tester.pumpWidget(buildWithMaterial(const FeedbackForm()));

    const message = 'Хочу больше поездок';
    await tester.enterText(find.byKey(const Key('feedback_field')), message);
    await tester.tap(find.byKey(const Key('send_feedback_button')));
    await tester.pump();

    expect(find.byKey(const Key('feedback_result')), findsOneWidget);
    expect(find.text('Последнее сообщение: $message'), findsOneWidget);
  });

  testWidgets('FeedbackForm clear button resets field', (tester) async {
    await tester.pumpWidget(buildWithMaterial(const FeedbackForm()));

    await tester.enterText(find.byKey(const Key('feedback_field')), 'text');
    await tester.tap(find.byKey(const Key('clear_feedback_button')));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byKey(const Key('feedback_field')));
    expect(textField.controller?.text ?? '', isEmpty);
    expect(find.byKey(const Key('feedback_result')), findsNothing);
  });

  testWidgets('FeedbackForm list supports drag scrolling', (tester) async {
    await tester.pumpWidget(buildWithMaterial(const FeedbackForm()));

    expect(find.text('Отзыв #0: Всё понравилось!'), findsOneWidget);
    await tester.drag(find.byKey(const Key('feedback_scroll_list')), const Offset(0, -400));
    await tester.pump();

    expect(find.text('Отзыв #0: Всё понравилось!'), findsNothing);
    expect(find.text('Отзыв #10: Всё понравилось!'), findsOneWidget);
  });

  testWidgets('PageViewScreen shows next page after horizontal drag', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PageViewScreen()));

    expect(find.text('Page 1'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Page 2'), findsOneWidget);
  });

  testWidgets('FeedbackForm keeps last message after multiple submits', (tester) async {
    await tester.pumpWidget(buildWithMaterial(const FeedbackForm()));

    await tester.enterText(find.byKey(const Key('feedback_field')), 'First');
    await tester.tap(find.byKey(const Key('send_feedback_button')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('feedback_field')), 'Second');
    await tester.tap(find.byKey(const Key('send_feedback_button')));
    await tester.pump();

    expect(find.byKey(const Key('feedback_result')), findsOneWidget);
    expect(find.text('Последнее сообщение: Second'), findsOneWidget);
    expect(find.text('Последнее сообщение: First'), findsNothing);
  });
}

