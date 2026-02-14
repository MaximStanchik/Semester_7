import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/screens/products/product_edit_screen.dart';

import 'test_utils/test_blocs.dart';

Finder _fieldByLabel(String label) {
  final input = find.byWidgetPredicate(
    (w) => w is InputDecorator && w.decoration.labelText == label,
  );
  return find.descendant(of: input, matching: find.byType(EditableText));
}

class _TestBanner extends StatelessWidget {
  final String text;

  const _TestBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Material(
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  testWidgets('Admin flow: add product dispatches ProductAddOrUpdateRequested', (tester) async {
    print('[integration] START: admin_add_product_test');
    final productBloc = TestProductBloc(initialState: const ProductInitial());

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            BlocProvider<ProductBloc>.value(
              value: productBloc,
              child: const ProductEditScreen(),
            ),
            const _TestBanner(text: 'RUNNING: Admin add product'),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(_fieldByLabel('Название'), 'Admin Product');
    await tester.enterText(_fieldByLabel('Цена'), '15');
    await tester.enterText(_fieldByLabel('Расположение'), 'Minsk');
    await tester.enterText(_fieldByLabel('Количество отзывов'), '0');
    await tester.enterText(_fieldByLabel('Описание'), 'Desc');

    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    final events = productBloc.events.whereType<ProductAddOrUpdateRequested>().toList();
    expect(events.length, 1);
    expect(events.single.product.title, 'Admin Product');

    final scaffoldFinder = find.byType(Scaffold);
    if (scaffoldFinder.evaluate().isNotEmpty) {
      final ctx = tester.element(scaffoldFinder.first);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('PASSED: Admin add product')),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    print('[integration] PASSED: admin_add_product_test');

    await productBloc.close();
  });
}
