import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:work_project/bloc/auth/auth_event.dart';
import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/bloc/favorites/favorites_event.dart';
import 'package:work_project/bloc/favorites/favorites_state.dart';
import 'package:work_project/bloc/product/product_event.dart';
import 'package:work_project/bloc/product/product_state.dart';

class TestAuthBloc extends Bloc<AuthEvent, AuthState> {
  final List<AuthEvent> events = <AuthEvent>[];

  TestAuthBloc({required AuthState initialState}) : super(initialState) {
    on<AuthEvent>((event, emit) {
      events.add(event);
    });
  }
}

class TestProductBloc extends Bloc<ProductEvent, ProductState> {
  final List<ProductEvent> events = <ProductEvent>[];

  TestProductBloc({required ProductState initialState}) : super(initialState) {
    on<ProductEvent>((event, emit) {
      events.add(event);
    });
  }
}

class TestFavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final List<FavoritesEvent> events = <FavoritesEvent>[];

  TestFavoritesBloc({required FavoritesState initialState}) : super(initialState) {
    on<FavoritesEvent>((event, emit) {
      events.add(event);
    });
  }
}
