import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthClientImpl implements AuthClient {
  final GoTrueClient client;
  final FunctionsClient functions;

  AuthClientImpl(this.client, this.functions);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return client.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    return await client.resetPasswordForEmail(email);
  }

  @override
  Future<AuthResponse> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    return await client.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
  }

  @override
  Future<UserResponse> updatePassword({required String password}) async {
    return await client.updateUser(UserAttributes(password: password));
  }

  @override
  Future<AuthResponse> signInWithIdToken(
    OAuthProvider provider,
    String idToken,
  ) async {
    return await client.signInWithIdToken(provider: provider, idToken: idToken);
  }

  @override
  Future<bool> signInWithOAuth(
    OAuthProvider provider,
    String callbackUrl,
  ) async {
    return await client.signInWithOAuth(
      provider,
      redirectTo: callbackUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signInWithOtp({required String phoneNumber}) async {
    await client.signInWithOtp(phone: phoneNumber);
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    return await client.verifyOTP(phone: phoneNumber, type: OtpType.sms);
  }

  @override
  User? get currentUser => client.currentUser;

  @override
  Future<void> signOut() async {
    return await client.signOut();
  }

  @override
  Stream<AuthState> get authStateChanges => client.onAuthStateChange;

  @override
  Future<UserResponse> updateUser(UserAttributes attributes) async {
    return await client.updateUser(attributes);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await functions.invoke('delete-account');
    await client.signOut(scope: SignOutScope.global);

    if (response.status != 200) {
      throw const AuthException('Failed to delete account');
    }
  }
}
