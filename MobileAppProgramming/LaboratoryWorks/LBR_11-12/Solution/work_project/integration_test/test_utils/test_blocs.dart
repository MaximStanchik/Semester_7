import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/auth/auth_event.dart';
import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/bloc/favorites/favorites_bloc.dart';
import 'package:work_project/bloc/favorites/favorites_event.dart';
import 'package:work_project/bloc/favorites/favorites_state.dart';
import 'package:work_project/bloc/product/product_bloc.dart';
import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_state.dart';
import 'package:work_project/models/product.dart';
import 'package:work_project/models/user_profile.dart';
import 'package:work_project/repositories/auth_repository.dart';
import 'package:work_project/repositories/firestore_favorites_repository.dart';
import 'package:work_project/repositories/firestore_product_repository.dart';
import 'package:work_project/repositories/user_profile_repository.dart';

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

class _FakeFavoritesRepository implements FirestoreFavoritesRepository {
  @override
  Stream<Set<String>> watchFavoriteProductIds(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetchFavoritesProducts({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isFavorite({required String userId, required String productId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorite({required String userId, required String productId}) {
    throw UnimplementedError();
  }
}

class TestAuthBloc extends AuthBloc {
  final List<AuthEvent> events = <AuthEvent>[];

  TestAuthBloc({required AuthState initialState})
      : super(
          authRepo: _FakeAuthRepository(),
          profileRepo: _FakeUserProfileRepository(),
        ) {
    emit(initialState);
  }

  @override
  void add(AuthEvent event) {
    events.add(event);
  }
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

class TestFavoritesBloc extends FavoritesBloc {
  final List<FavoritesEvent> events = <FavoritesEvent>[];

  TestFavoritesBloc({required FavoritesState initialState}) : super(repo: _FakeFavoritesRepository()) {
    emit(initialState);
  }

  @override
  void add(FavoritesEvent event) {
    events.add(event);
  }

  @override
  bool isFavorite(String userId, Product product) {
    final current = state;
    if (current is FavoritesLoaded) {
      return current.favorites.any((p) => p.id == product.id);
    }
    return false;
  }
}
