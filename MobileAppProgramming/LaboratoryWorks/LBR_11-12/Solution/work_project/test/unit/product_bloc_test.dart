import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/models/product.dart';
import 'package:work_project/repositories/firestore_product_repository.dart';

class MockFirestoreProductRepository extends Mock implements FirestoreProductRepository {
  @override
  Stream<List<Product>> watchAll() => super.noSuchMethod(
        Invocation.method(#watchAll, []),
        returnValue: const Stream<List<Product>>.empty(),
        returnValueForMissingStub: const Stream<List<Product>>.empty(),
      ) as Stream<List<Product>>;

  @override
  Future<List<Product>> fetchAll() => super.noSuchMethod(
        Invocation.method(#fetchAll, []),
        returnValue: Future<List<Product>>.value(const <Product>[]),
        returnValueForMissingStub: Future<List<Product>>.value(const <Product>[]),
      ) as Future<List<Product>>;
}

void main() {
  group('ProductBloc (unit, Mockito)', () {
    late MockFirestoreProductRepository repo;

    setUp(() {
      repo = MockFirestoreProductRepository();
    });

    test('ProductLoadRequested eventually emits ProductLoaded and calls repository', () async {
      final products = [
        Product(
          id: '1',
          title: 'Milk',
          imagePath: '',
          price: 10,
          location: 'Minsk',
          reviewsCount: 0,
          description: 'Desc',
        ),
      ];

      when(repo.watchAll()).thenAnswer((_) => Stream.value(products));
      when(repo.fetchAll()).thenAnswer((_) async => products);

      final bloc = ProductBloc(repo: repo);
      await bloc.stream.where((s) => s is ProductLoaded).cast<ProductLoaded>().first;

      verify(repo.watchAll()).called(1);
      verify(repo.fetchAll()).called(greaterThanOrEqualTo(1));
      await bloc.close();
    });
  });
}
