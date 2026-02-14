part of 'app_bloc.dart';

class AppState extends Equatable {
  final List<AppUser> users;
  final AppUser? currentUser;
  final List<Product> products;
  final List<FavoriteItem> favorites;
  final List<SearchHistory> history;

  const AppState({required this.users, required this.currentUser, required this.products, required this.favorites, required this.history});

  const AppState.initial() : users = const [], currentUser = null, products = const [], favorites = const [], history = const [];

  AppState copyWith({List<AppUser>? users, AppUser? currentUser, List<Product>? products, List<FavoriteItem>? favorites, List<SearchHistory>? history}) {
    return AppState(
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      products: products ?? this.products,
      favorites: favorites ?? this.favorites,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [users, currentUser, products, favorites, history];
}


