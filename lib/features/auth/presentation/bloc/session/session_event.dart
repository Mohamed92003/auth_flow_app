import 'package:equatable/equatable.dart';
import 'package:auth_flow_app/features/auth/domain/entities/user_entity.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends SessionEvent {
  const CheckAuthStatusEvent();
}

class SignOutEvent extends SessionEvent {
  const SignOutEvent();
}

class AuthStateChangedEvent extends SessionEvent {
  final UserEntity? user;

  const AuthStateChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateCurrentUserEvent extends SessionEvent {
  final UserEntity user;

  const UpdateCurrentUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
