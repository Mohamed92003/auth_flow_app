import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/features/auth/data/datasources/email_auth_datasource.dart';
import 'package:auth_flow_app/features/auth/data/models/user_model.dart';

class EmailAuthDataSourceImpl implements EmailAuthDataSource {
  final AuthClient _authClient;

  EmailAuthDataSourceImpl(this._authClient);

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _authClient.signUp(
        email: email,
        password: password,
        name: name,
      );
      if (response.user == null) {
        throw AuthException('Signup Failed - No user returned');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign up: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authClient.signIn(email: email, password: password);
      if (response.user == null) {
        throw AuthException('SignIn Failed - Invalid credentials');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _authClient.resetPasswordForEmail(email: email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _authClient.verifyPasswordResetOTP(email: email, otp: otp);
      if (response.user == null) {
        throw AuthException('Verification OTP Failed - Invalidate OTP or Expire');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      await _authClient.updatePassword(password: password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMagicLink({required String email}) {
    // TODO: implement sendMagicLink
    throw UnimplementedError();
  }

}