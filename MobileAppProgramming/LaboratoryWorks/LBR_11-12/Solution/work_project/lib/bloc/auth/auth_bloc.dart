import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_profile_repository.dart';
import '../../services/analytics_service.dart';
import '../../services/presence_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;
  final UserProfileRepository _profileRepo;

  StreamSubscription<User?>? _authSub;

  AuthBloc({
    AuthRepository? authRepo,
    UserProfileRepository? profileRepo,
  })  : _authRepo = authRepo ?? AuthRepository(),
        _profileRepo = profileRepo ?? UserProfileRepository(),
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInEmailRequested>(_onSignInEmailRequested);
    on<AuthSignUpEmailRequested>(_onSignUpEmailRequested);
    on<AuthSendPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignInWithGoogleRequested>(_onGoogleRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    add(const AuthStarted());
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _authSub?.cancel();
    _authSub = _authRepo.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    final user = event.user;
    if (user == null) {
      try {
        await PresenceService.instance.stop();
      } catch (_) {
        // ignore presence errors (e.g. Firebase not initialized in tests)
      }
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      try {
        await PresenceService.instance.start(uid: user.uid);
      } catch (_) {
        // ignore presence errors (e.g. Firebase not initialized in tests)
      }
      final profile = await _profileRepo
          .getOrCreateProfile(user)
          .timeout(const Duration(seconds: 6), onTimeout: () {
        final email = user.email;
        final name = user.displayName ?? (email != null ? email.split('@').first : 'User');
        return UserProfile(
          uid: user.uid,
          email: email,
          name: name,
          role: 'viewer',
          avatarUrl: user.photoURL,
        );
      });
      emit(AuthAuthenticated(profile: profile));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInEmailRequested(
    AuthSignInEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await AnalyticsService.instance.logEvent('login_email');
      await _authRepo.signInWithEmail(email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? e.code, code: e.code));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpEmailRequested(
    AuthSignUpEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await AnalyticsService.instance.logEvent('signup_email');
      await _authRepo.signUpWithEmail(email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? e.code, code: e.code));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthSendPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepo.sendPasswordResetEmail(email: event.email);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? e.code, code: e.code));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await AnalyticsService.instance.logEvent('login_google');
      await _authRepo.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? e.code, code: e.code));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());

    () async {
      try {
        await AnalyticsService.instance.logEvent('logout');
      } catch (_) {}

      try {
        await PresenceService.instance.stop();
      } catch (_) {}

      try {
        await _authRepo.signOut();
      } catch (_) {}
    }();
  }

  @override
  Future<void> close() async {
    try {
      await PresenceService.instance.stop();
    } catch (_) {
      // ignore presence errors (e.g. Firebase not initialized in tests)
    }
    await _authSub?.cancel();
    return super.close();
  }
}
