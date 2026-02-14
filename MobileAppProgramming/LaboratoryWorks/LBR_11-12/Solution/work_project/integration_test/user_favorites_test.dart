import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/favorites/favorites_bloc.dart';
import 'package:work_project/bloc/favorites/favorites_event.dart';
import 'package:work_project/bloc/favorites/favorites_state.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/models/product.dart';
import 'package:work_project/models/user_profile.dart';
import 'package:work_project/screens/products/product_detail_screen.dart';

import 'test_utils/test_blocs.dart';

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

  testWidgets('User flow: tap favorites dispatches FavoriteToggleRequested', (tester) async {
    print('[integration] START: user_favorites_test');
    final authBloc = TestAuthBloc(
      initialState: const AuthAuthenticated(
        profile: UserProfile(uid: 'u1', name: 'User', role: 'viewer', email: 'u@e.com'),
      ),
    );

    final favoritesBloc = TestFavoritesBloc(initialState: const FavoritesLoaded(favorites: [], userId: 'u1'));

    final product = Product(
      id: 'p1',
      title: 'Milk',
      imagePath: '',
      price: 10,
      location: 'Minsk',
      reviewsCount: 0,
      description: 'Desc',
      isLiked: false,
    );

    final productBloc = TestProductBloc(initialState: ProductLoaded(products: [product]));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
          BlocProvider<ProductBloc>.value(value: productBloc),
        ],
        child: MaterialApp(
          home: Stack(
            children: [
              ProductDetailScreen(product: product),
              const _TestBanner(text: 'RUNNING: User favorites'),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('В избранное'));
    await tester.pump();

    final events = favoritesBloc.events.whereType<FavoriteToggleRequested>().toList();
    expect(events.length, 1);
    expect(events.single.userId, 'u1');
    expect(events.single.product.id, 'p1');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(),
              _TestBanner(text: 'PASSED: User favorites'),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    print('[integration] PASSED: user_favorites_test');

    await authBloc.close();
    await favoritesBloc.close();
    await productBloc.close();
  });
}
