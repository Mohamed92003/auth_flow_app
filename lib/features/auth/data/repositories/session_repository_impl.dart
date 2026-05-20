import 'package:dartz/dartz.dart';
import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/error/failures.dart';
import 'package:auth_flow_app/features/auth/data/datasources/session_datasource.dart';
import 'package:auth_flow_app/features/auth/domain/entities/user_entity.dart';
import 'package:auth_flow_app/features/auth/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionDataSource _sessionDataSource;

  SessionRepositoryImpl({
    required SessionDataSource sessionDataSource,
  }) : _sessionDataSource = sessionDataSource;

  @override
  Either<Failure, UserEntity?> getCurrentUser()  {
    try {
      final user =  _sessionDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _sessionDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _sessionDataSource.authStateChanges;
  }
}