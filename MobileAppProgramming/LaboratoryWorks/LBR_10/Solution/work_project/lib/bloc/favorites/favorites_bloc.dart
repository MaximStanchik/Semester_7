import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/favorite_entry.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final HiveService _hiveService = HiveService.instance;

  FavoritesBloc() : super(const FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onFavoritesLoadRequested);
    on<FavoriteToggleRequested>(_onFavoriteToggleRequested);
  }

  Future<void> _onFavoritesLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(const FavoritesLoading());
      final favorites = _hiveService.getFavoritesForUser(event.userId);
      emit(FavoritesLoaded(favorites: favorites, userId: event.userId));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onFavoriteToggleRequested(
    FavoriteToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _hiveService.toggleFavorite(event.userId, event.product);
      add(FavoritesLoadRequested(event.userId));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  ValueListenable<Box<FavoriteEntry>> watchFavorites() => _hiveService.watchFavorites();

  bool isFavorite(int userId, Product product) {
    return _hiveService.isFavorite(userId, product);
  }

  List<Product> getFavoritesForUser(int userId) {
    return _hiveService.getFavoritesForUser(userId);
  }
}

