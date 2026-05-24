import 'dart:async';

import 'package:auth_flow_app/features/auth/domain/repositories/session_repository.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/session/session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository sessionRepository;
  StreamSubscription? _authStateSubscription;

  SessionBloc({required this.sessionRepository}) : super(const SessionInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignOutEvent>(_onSignOut);
    on<AuthStateChangedEvent>(_onAuthStateChanged);
    on<UpdateCurrentUserEvent>(_onUpdateCurrentUser);

    _authStateSubscription = sessionRepository.authStateChanges.listen((user) {
      add(AuthStateChangedEvent(user));
    });
  }

  void _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<SessionState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(user: event.user!));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());

    final result = sessionRepository.getCurrentUser();

    result.fold((failure) => emit(SessionError(message: failure.message)), (
      user,
    ) {
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());

    final result = await sessionRepository.signOut();

    result.fold(
      (failure) => emit(SessionError(message: failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  void _onUpdateCurrentUser(
      UpdateCurrentUserEvent event,
      Emitter<SessionState> emit,
      ) {
    emit(Authenticated(user: event.user));
  }
}
