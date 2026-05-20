import 'package:auth_flow_app/core/error/failures.dart';
import 'package:auth_flow_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class SessionRepository {
  Either<Failure, UserEntity?> getCurrentUser();

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> get authStateChanges;
}
