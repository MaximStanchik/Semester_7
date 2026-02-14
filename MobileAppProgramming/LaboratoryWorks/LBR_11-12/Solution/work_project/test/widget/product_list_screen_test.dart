import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/models/product.dart';
import 'package:work_project/models/user_profile.dart';
import 'package:work_project/repositories/auth_repository.dart';
import 'package:work_project/repositories/user_profile_repository.dart';
import 'package:work_project/repositories/firestore_product_repository.dart';
import 'package:work_project/screens/products/product_list_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }
}

class _FakeUserProfileRepository implements UserProfileRepository {
  @override
  Future<UserProfile> getOrCreateProfile(User user) {
    throw UnimplementedError();
  }

  @override
  Stream<UserProfile> watchProfile(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsertProfile(UserProfile profile) {
    throw UnimplementedError();
  }
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

class TestAuthBloc extends AuthBloc {
  TestAuthBloc({required AuthState initialState})
      : super(
          authRepo: _FakeAuthRepository(),
          profileRepo: _FakeUserProfileRepository(),
        ) {
    emit(initialState);
  }

  @override
  void add(event) {}
}

class TestProductBloc extends ProductBloc {
  final List<ProductEvent> events = <ProductEvent>[];

  TestProductBloc({required ProductState initialState}) : super(repo: _FakeProductRepository()) {
    emit(initialState);
  }

  @override
  void add(ProductEvent event) {
    events.add(event);
  }
}

List<Product> _buildProducts(int count) {
  return List<Product>.generate(
    count,
    (index) => Product(
      id: 'p$index',
      title: 'Product $index',
      imagePath: '',
      price: 0,
      location: 'Minsk',
      reviewsCount: 0,
      description: '',
    ),
    growable: false,
  );
}

void main() {
  testWidgets('ProductListScreen tap opens Analytics demo screen', (tester) async {
    print('[widget] START: ProductListScreen tap opens Analytics demo screen');
    final authBloc = TestAuthBloc(
      initialState: AuthAuthenticated(
        profile: UserProfile(uid: 'u1', name: 'User', role: 'viewer', email: 'u@e.com'),
      ),
    );
    final productBloc = TestProductBloc(
      initialState: ProductLoaded(products: _buildProducts(20)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProductBloc>.value(value: productBloc),
          ],
          child: const Scaffold(body: ProductListScreen()),
        ),
      ),
    );

    await tester.pump();
    print('[widget] Tap: Безопасность');

    await tester.tap(find.text('Безопасность'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.widgetWithText(AppBar, 'Безопасность'), findsOneWidget);
    print('[widget] Now on SecurityToolsScreen, tap: Analytics (демо)');

    await tester.tap(find.text('Analytics (демо)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.widgetWithText(AppBar, 'Analytics (демо)'), findsOneWidget);

    expect(find.text('demo_screen_open'), findsOneWidget);
    print('[widget] ASSERT OK: demo_screen_open visible');

    authBloc.close();
    productBloc.close();
    print('[widget] PASSED: ProductListScreen tap opens Analytics demo screen');
  });

  testWidgets('ProductListScreen drag reveals lower items', (tester) async {
    print('[widget] START: ProductListScreen drag reveals lower items');
    final authBloc = TestAuthBloc(
      initialState: AuthAuthenticated(
        profile: UserProfile(uid: 'u1', name: 'User', role: 'viewer', email: 'u@e.com'),
      ),
    );
    final productBloc = TestProductBloc(
      initialState: ProductLoaded(products: _buildProducts(20)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProductBloc>.value(value: productBloc),
          ],
          child: const Scaffold(body: ProductListScreen()),
        ),
      ),
    );

    await tester.pump();

    print('[widget] Tap: Безопасность');
    await tester.tap(find.text('Безопасность'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.widgetWithText(AppBar, 'Безопасность'), findsOneWidget);

    expect(find.text('Попытка чтения с неправильным ключом'), findsNothing);
    print('[widget] Drag until visible: Попытка чтения с неправильным ключом');

    final scrollable = find.byType(ListView).last;

    final target = find.text('Попытка чтения с неправильным ключом');
    for (var i = 0; i < 30; i++) {
      if (target.evaluate().isNotEmpty) break;
      await tester.drag(scrollable, const Offset(0, -400), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Попытка чтения с неправильным ключом'), findsWidgets);
    print('[widget] ASSERT OK: target visible');

    authBloc.close();
    productBloc.close();
    print('[widget] PASSED: ProductListScreen drag reveals lower items');
  });
}
