import 'package:equatable/equatable.dart';
import '../../models/app_user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final AppUser? activeUser;
  final List<AppUser> users;
  final bool canManageProducts;

  const UserLoaded({
    required this.activeUser,
    required this.users,
    required this.canManageProducts,
  });

  @override
  List<Object?> get props => [activeUser, users, canManageProducts];

  UserLoaded copyWith({
    AppUser? activeUser,
    List<AppUser>? users,
    bool? canManageProducts,
  }) {
    return UserLoaded(
      activeUser: activeUser ?? this.activeUser,
      users: users ?? this.users,
      canManageProducts: canManageProducts ?? this.canManageProducts,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

