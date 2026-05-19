import 'package:auth_flow_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SocialAuthState extends Equatable {
  const SocialAuthState();

  @override
  List<Object?> get props => [];
}

class SocialAuthInitial extends SocialAuthState {
  const SocialAuthInitial();
}

class SocialAuthLoading extends SocialAuthState {
  const SocialAuthLoading();
}

class SocialAuthSuccess extends SocialAuthState {
  final UserEntity user;

  const SocialAuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class SocialAuthLaunched extends SocialAuthState {
  const SocialAuthLaunched();

  @override
  List<Object?> get props => [];
}

class SocialAuthError extends SocialAuthState {
  final String message;

  const SocialAuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
