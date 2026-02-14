import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<Product> favorites;
  final int userId;

  const FavoritesLoaded({
    required this.favorites,
    required this.userId,
  });

  @override
  List<Object?> get props => [favorites, userId];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

