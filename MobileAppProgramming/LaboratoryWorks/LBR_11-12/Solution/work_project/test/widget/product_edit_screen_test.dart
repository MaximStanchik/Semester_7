import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/models/product.dart';
import 'package:work_project/repositories/firestore_product_repository.dart';
import 'package:work_project/screens/products/product_edit_screen.dart';

Finder _fieldByLabel(String label) {
  final input = find.byWidgetPredicate(
    (w) => w is InputDecorator && w.decoration.labelText == label,
  );
  return find.descendant(of: input, matching: find.byType(EditableText));
}

class _FakeProductRepository implements FirestoreProductRepository {
  @override
  Future<void> deleteById(String productId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetchAll() {
    throw UnimplementedError();
  }

  @override
  Future<void> incrementReviewsCount(String productId, int delta) {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleLike(String productId) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(Product product) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Product>> watchAll() {
    throw UnimplementedError();
  }
}

class TestProductBloc extends ProductBloc {
  final List<ProductEvent> events = <ProductEvent>[];

  TestProductBloc() : super(repo: _FakeProductRepository());

  @override
  void add(ProductEvent event) {
    events.add(event);
  }
}

void main() {
  testWidgets('ProductEditScreen renders and allows typing in fields', (tester) async {
    print('[widget] START: ProductEditScreen renders and allows typing in fields');
    final productBloc = TestProductBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: productBloc,
          child: const ProductEditScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Добавить товар'), findsOneWidget);

    print('[widget] Enter fields: Название/Цена');
    await tester.enterText(_fieldByLabel('Название'), 'Test Product');
    await tester.enterText(_fieldByLabel('Цена'), '10');

    productBloc.close();
    print('[widget] PASSED: ProductEditScreen renders and allows typing in fields');
  });

  testWidgets('ProductEditScreen drag scrolls form list', (tester) async {
    print('[widget] START: ProductEditScreen drag scrolls form list');
    final productBloc = TestProductBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: productBloc,
          child: const ProductEditScreen(),
        ),
      ),
    );

    expect(find.text('Описание'), findsOneWidget);
    print('[widget] Drag scroll');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pump();

    productBloc.close();
    print('[widget] PASSED: ProductEditScreen drag scrolls form list');
  });
}
