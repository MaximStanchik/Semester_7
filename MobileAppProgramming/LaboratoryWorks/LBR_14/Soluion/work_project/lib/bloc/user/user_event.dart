import 'package:equatable/equatable.dart';
import '../../models/app_user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoadRequested extends UserEvent {
  const UserLoadRequested();
}

class UserSelected extends UserEvent {
  final AppUser user;

  const UserSelected(this.user);

  @override
  List<Object?> get props => [user];
}

