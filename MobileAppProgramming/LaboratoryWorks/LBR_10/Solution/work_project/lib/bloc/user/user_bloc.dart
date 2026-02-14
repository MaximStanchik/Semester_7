import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_user.dart';
import '../../services/hive_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final HiveService _hiveService = HiveService.instance;

  UserBloc() : super(const UserInitial()) {
    on<UserLoadRequested>(_onUserLoadRequested);
    on<UserSelected>(_onUserSelected);
    
    add(const UserLoadRequested());
  }

  Future<void> _onUserLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      final users = _hiveService.getUsers();
      final activeUser = users.isNotEmpty ? users.first : null;
      final canManage = activeUser != null 
          ? _hiveService.canManageProducts(activeUser)
          : false;

      emit(UserLoaded(
        activeUser: activeUser,
        users: users,
        canManageProducts: canManage,
      ));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserSelected(
    UserSelected event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserLoaded) {
        final currentState = state as UserLoaded;
        if (currentState.activeUser?.id != event.user.id) {
          final canManage = _hiveService.canManageProducts(event.user);
          emit(currentState.copyWith(
            activeUser: event.user,
            canManageProducts: canManage,
          ));
        }
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

