import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthClient {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> resetPasswordForEmail({required String email});

  Future<AuthResponse> verifyPasswordResetOTP({
    required String email,
    required String otp,
  });

  Future<UserResponse> updatePassword({required String password});

  Future<AuthResponse> signInWithIdToken(
    OAuthProvider provider,
    String idToken,
  );

  Future<bool> signInWithOAuth(OAuthProvider provider, String callbackUrl);

  Future<void> signInWithOtp({required String phoneNumber});

  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  User? get currentUser;

  Future<void> signOut();
  Stream<AuthState> get authStateChanges;

  Future<UserResponse> updateUser(UserAttributes attributes);

  Future<void> deleteAccount();
}
