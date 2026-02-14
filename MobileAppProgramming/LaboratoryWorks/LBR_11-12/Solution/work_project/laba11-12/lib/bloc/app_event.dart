part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class SetCurrentUser extends AppEvent {
  final AppUser? user;
  const SetCurrentUser(this.user);

  @override
  List<Object?> get props => [user];
}

class AddSearchHistoryEvent extends AppEvent {
  final String query;
  const AddSearchHistoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class EnsureDefaultUsers extends AppEvent {
  final List<AppUser> usersToCreate;
  const EnsureDefaultUsers(this.usersToCreate);

  @override
  List<Object?> get props => [usersToCreate];
}

class AddUserEvent extends AppEvent {
  final AppUser user;
  const AddUserEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends AppEvent {
  final String userId;
  const DeleteUserEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFavoriteEvent extends AppEvent {
  final String userId;
  final String productId;
  const ToggleFavoriteEvent(this.userId, this.productId);
  @override
  List<Object?> get props => [userId, productId];
}

abstract class ProductCrudEvent extends AppEvent {
  Future<void> apply(AppProvider provider);
}

class UpsertProductEvent extends ProductCrudEvent {
  final Product data;
  UpsertProductEvent(this.data);
  @override
  Future<void> apply(AppProvider provider) async {
    await provider.addProduct(data);
  }
}

class DeleteProductEvent extends ProductCrudEvent {
  final String productId;
  DeleteProductEvent(this.productId);
  @override
  Future<void> apply(AppProvider provider) async {
    await provider.deleteProduct(productId);
  }
}

class DeleteSearchHistoryEvent extends AppEvent {
  final String historyId;
  const DeleteSearchHistoryEvent(this.historyId);
  @override
  List<Object?> get props => [historyId];
}

class DeleteUsersByRoleEvent extends AppEvent {
  final UserRole role;
  const DeleteUsersByRoleEvent(this.role);
  @override
  List<Object?> get props => [role];
}


