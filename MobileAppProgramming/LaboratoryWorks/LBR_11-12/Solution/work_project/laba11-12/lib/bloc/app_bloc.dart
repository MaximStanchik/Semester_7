import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';
import '../models/history.dart';
import '../models/role.dart';
import '../providers/app_provider.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AppProvider appProvider;

  AppBloc({required this.appProvider}) : super(const AppState.initial()) {
    on<AppStarted>((event, emit) {
      emit(state.copyWith(
        users: appProvider.users,
        currentUser: appProvider.currentUser,
        products: appProvider.products,
        favorites: appProvider.favorites,
        history: appProvider.history,
      ));
    });

    on<SetCurrentUser>((event, emit) async {
      await appProvider.setCurrentUser(event.user);
      emit(state.copyWith(currentUser: appProvider.currentUser));
    });

    on<AddSearchHistoryEvent>((event, emit) async {
      if (state.currentUser == null) return;
      await appProvider.addSearchHistory(state.currentUser!.id, event.query);
      emit(state.copyWith(history: appProvider.history));
    });

    on<EnsureDefaultUsers>((event, emit) async {
      if (appProvider.users.isEmpty) {
        for (final u in event.usersToCreate) {
          await appProvider.addUser(u);
        }
        emit(state.copyWith(users: appProvider.users));
      }
    });

    on<AddUserEvent>((event, emit) async {
      await appProvider.addUser(event.user);
      emit(state.copyWith(users: appProvider.users));
    });

    on<DeleteUserEvent>((event, emit) async {
      await appProvider.deleteUser(event.userId);
      emit(state.copyWith(users: appProvider.users, currentUser: appProvider.currentUser));
    });

    on<ToggleFavoriteEvent>((event, emit) async {
      await appProvider.toggleFavorite(event.userId, event.productId);
      emit(state.copyWith(favorites: appProvider.favorites));
    });

    on<ProductCrudEvent>((event, emit) async {
      await event.apply(appProvider);
      emit(state.copyWith(products: appProvider.products));
    });

    on<DeleteSearchHistoryEvent>((event, emit) async {
      await appProvider.historyProvider.deleteSearchHistory(event.historyId);
      emit(state.copyWith(history: appProvider.history));
    });

    on<DeleteUsersByRoleEvent>((event, emit) async {
      final usersToDelete = appProvider.userProvider.getUsersByRole(event.role);
      for (final u in usersToDelete) {
        // очистим связанные данные
        final favs = appProvider.favoriteProvider.getFavoritesByUser(u.id);
        for (final f in favs) {
          await appProvider.favoriteProvider.removeFromFavorites(f.userId, f.productId);
        }
        await appProvider.historyProvider.clearUserHistory(u.id);
        await appProvider.deleteUser(u.id);
      }
      emit(state.copyWith(
        users: appProvider.users,
        currentUser: appProvider.currentUser,
        favorites: appProvider.favorites,
        history: appProvider.history,
      ));
    });
  }
}


