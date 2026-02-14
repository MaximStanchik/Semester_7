import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../../repositories/firestore_favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

import 'dart:async';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirestoreFavoritesRepository _repo;

  StreamSubscription<Set<String>>? _favIdsSub;
  String? _activeUserId;
  Set<String> _favoriteProductIds = <String>{};

  FavoritesBloc({FirestoreFavoritesRepository? repo})
      : _repo = repo ?? FirestoreFavoritesRepository(),
        super(const FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onFavoritesLoadRequested);
    on<FavoriteToggleRequested>(_onFavoriteToggleRequested);
    on<FavoritesIdsUpdated>(_onFavoritesIdsUpdated);
  }

  Future<void> _onFavoritesLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(const FavoritesLoading());

      _activeUserId = event.userId;

      _favIdsSub?.cancel();
      _favIdsSub = _repo.watchFavoriteProductIds(event.userId).listen(
        (ids) {
          add(
            FavoritesIdsUpdated(
              userId: event.userId,
              productIds: ids,
            ),
          );
        },
      );

      final favorites = await _repo.fetchFavoritesProducts(userId: event.userId);
      emit(FavoritesLoaded(favorites: favorites, userId: event.userId));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onFavoritesIdsUpdated(
    FavoritesIdsUpdated event,
    Emitter<FavoritesState> emit,
  ) async {
    _favoriteProductIds = event.productIds;

    final favorites = await _repo.fetchFavoritesProducts(userId: event.userId);
    emit(FavoritesLoaded(favorites: favorites, userId: event.userId));
  }

  Future<void> _onFavoriteToggleRequested(
    FavoriteToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _repo.toggleFavorite(
        userId: event.userId,
        productId: event.product.id,
      );
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  bool isFavorite(String userId, Product product) {
    if (_activeUserId != userId) return false;
    return _favoriteProductIds.contains(product.id);
  }

  @override
  Future<void> close() async {
    await _favIdsSub?.cancel();
    return super.close();
  }
}

