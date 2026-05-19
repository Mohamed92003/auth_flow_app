import 'package:auth_flow_app/features/auth/domain/repositories/social_auth_repository.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/social_auth/social_auth_event.dart';
import 'package:auth_flow_app/features/auth/presentation/bloc/social_auth/social_auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialAuthBloc extends Bloc<SocialAuthEvent, SocialAuthState> {
  final SocialAuthRepository socialAuthRepository;

  SocialAuthBloc({required this.socialAuthRepository})
    : super(const SocialAuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithAppleEvent>(_onSignInWithApple);
    on<SignInWithGitHubEvent>(_onSignInWithGitHub);
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<SocialAuthState> emit,
  ) async {
    emit(const SocialAuthLoading());

    final result = await socialAuthRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(SocialAuthError(message: failure.message)),
      (user) => emit(SocialAuthSuccess(user: user)),
    );
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleEvent event,
    Emitter<SocialAuthState> emit,
  ) async {
    emit(const SocialAuthLoading());

    final result = await socialAuthRepository.signInWithApple();

    result.fold(
      (failure) => emit(SocialAuthError(message: failure.message)),
      (user) => emit(SocialAuthSuccess(user: user)),
    );
  }

  Future<void> _onSignInWithGitHub(
    SignInWithGitHubEvent event,
    Emitter<SocialAuthState> emit,
  ) async {
    emit(const SocialAuthLoading());

    final result = await socialAuthRepository.signInWithGitHub();

    result.fold(
      (failure) => emit(SocialAuthError(message: failure.message)),
      (user) => emit(const SocialAuthLaunched()),
    );
  }
}
