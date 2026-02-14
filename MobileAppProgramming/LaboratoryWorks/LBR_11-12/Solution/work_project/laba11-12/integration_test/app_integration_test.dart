import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:laba3/bloc/app_bloc.dart';
import 'package:laba3/models/favorite.dart';
import 'package:laba3/models/product.dart';
import 'package:laba3/models/role.dart';
import 'package:laba3/models/user.dart';
import 'package:laba3/models/history.dart';
import 'package:laba3/providers/app_provider.dart';
import 'package:laba3/ui/products_page.dart';
import 'package:laba3/ui/user_dashboard_page.dart';

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

class MockAppProvider extends Mock implements AppProvider {
  @override
  Future<void> addProduct(product) => super.noSuchMethod(
        Invocation.method(#addProduct, [product]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> toggleFavorite(String userId, String productId) =>
      super.noSuchMethod(
        Invocation.method(#toggleFavorite, [userId, productId]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration tests', () {
    testWidgets('Admin adds new trip', (tester) async {
      print('[integration] START: laba11-12 Admin adds new trip');
      final mockProvider = MockAppProvider();
      final admin = AppUser(id: 'admin', name: 'Admin', role: UserRole.admin);
      final products = <Product>[
        Product(
          id: 'p1',
          title: 'Paris Getaway',
          imagePath: 'assets/mountain.jpg',
          price: 150,
          location: 'Paris',
          reviewsCount: 20,
          description: 'City lights',
          liked: false,
        ),
      ];

      when(mockProvider.users).thenReturn([admin]);
      when(mockProvider.currentUser).thenReturn(admin);
      when(mockProvider.products).thenReturn(products);
      when(mockProvider.favorites).thenReturn(<FavoriteItem>[]);
      when(mockProvider.history).thenReturn(<SearchHistory>[]);
      when(mockProvider.addProduct(any)).thenAnswer((invocation) async {
        final Product newProduct = invocation.positionalArguments.first;
        products.removeWhere((p) => p.id == newProduct.id);
        products.add(newProduct);
      });

      final bloc = AppBloc(appProvider: mockProvider);
      bloc.add(const AppStarted());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Stack(
              children: [
                ProductsPage(currentUser: admin),
                const _TestBanner(text: 'RUNNING: Admin adds new trip'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'New Adventure');
      await tester.enterText(find.byType(TextField).at(1), 'assets/forest.jpg');
      await tester.enterText(find.byType(TextField).at(2), '299');
      await tester.enterText(find.byType(TextField).at(3), 'Iceland');
      await tester.enterText(find.byType(TextField).at(4), '42');
      await tester.enterText(find.byType(TextField).at(5), 'Northern lights tour');
      await tester.tap(find.text('Создать'));
      await tester.pumpAndSettle();

      // Проверяем, что провайдер был вызван и список продуктов обновился
      verify(mockProvider.addProduct(any)).called(1);
      expect(products.length, 2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox.expand(),
                _TestBanner(text: 'PASSED: Admin adds new trip'),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      print('[integration] PASSED: laba11-12 Admin adds new trip');
      await bloc.close();
    });

    testWidgets('User can add trip to favorites', (tester) async {
      print('[integration] START: laba11-12 User can add trip to favorites');
      final mockProvider = MockAppProvider();
      final user = AppUser(id: 'user1', name: 'Olga', role: UserRole.user);
      final products = <Product>[
        Product(
          id: 'p2',
          title: 'Milan Weekend',
          imagePath: 'assets/forest.jpg',
          price: 120,
          location: 'Milan',
          reviewsCount: 12,
          description: 'Shopping',
          liked: false,
        ),
      ];
      final favorites = <FavoriteItem>[];

      when(mockProvider.users).thenReturn([user]);
      when(mockProvider.currentUser).thenReturn(user);
      when(mockProvider.products).thenReturn(products);
      when(mockProvider.favorites).thenReturn(favorites);
      when(mockProvider.history).thenReturn(<SearchHistory>[]);
      when(mockProvider.toggleFavorite(user.id, products.first.id))
          .thenAnswer((invocation) async {
        favorites
          ..clear()
          ..add(FavoriteItem(userId: user.id, productId: products.first.id));
      });

      final bloc = AppBloc(appProvider: mockProvider);
      bloc.add(const AppStarted());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Stack(
              children: [
                ProductsPage(currentUser: user),
                const _TestBanner(text: 'RUNNING: User adds to favorites'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();

      expect(bloc.state.favorites.length, 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox.expand(),
                _TestBanner(text: 'PASSED: User adds to favorites'),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      print('[integration] PASSED: laba11-12 User can add trip to favorites');
      await bloc.close();
    });

    testWidgets('User dashboard shows user information', (tester) async {
      print('[integration] START: laba11-12 User dashboard shows user information');
      final user = AppUser(id: 'user2', name: 'Irina', role: UserRole.user);

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              UserDashboardPage(currentUser: user),
              const _TestBanner(text: 'RUNNING: User dashboard info'),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Irina'), findsOneWidget);
      expect(find.text('Моё избранное'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox.expand(),
                _TestBanner(text: 'PASSED: User dashboard info'),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      print('[integration] PASSED: laba11-12 User dashboard shows user information');
    });
  });
}

