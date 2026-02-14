import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoritesEvent {
  final int userId;

  const FavoritesLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FavoriteToggleRequested extends FavoritesEvent {
  final int userId;
  final Product product;

  const FavoriteToggleRequested({
    required this.userId,
    required this.product,
  });

  @override
  List<Object?> get props => [userId, product];
}

