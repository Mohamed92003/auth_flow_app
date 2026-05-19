import 'package:auth_flow_app/features/auth/data/models/user_model.dart';
import 'package:auth_flow_app/features/auth/domain/entities/user_entity.dart';

abstract class EmailAuthDataSource {
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> signInWithEmail({required String email, required String password});

  Future<void> resetPassword({required String email});

  Future<UserEntity> verifyPasswordResetOtp({required String email, required String otp});

  Future<void> updatePassword({required String password});

  Future<void> sendMagicLink({required String email});
}
