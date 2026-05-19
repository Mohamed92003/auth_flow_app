import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/features/auth/data/models/user_model.dart';
import 'package:auth_flow_app/features/auth/data/datasources/social_auth_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class SocialAuthDataSourceImpl implements SocialAuthDataSource {
  final AuthClient _authClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isInitialize = false;

  SocialAuthDataSourceImpl(this._authClient);

  Future ensureInitialized() async {
    if (isInitialize) return;
    await _googleSignIn.initialize(
      serverClientId:
          '4643811137-qli66ulllnud59gfrppt0r63eej6njla.apps.googleusercontent.com',
    );
    isInitialize = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await ensureInitialized();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Auth with Google failed');
      }
      final authResponse = await _authClient.signInWithIdToken(
        OAuthProvider.google,
        idToken,
      );
      if (authResponse.user == null) {
        throw ServerException('Failed to signIn with Google');
      }
      return UserModel.fromSupabaseUser(authResponse.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // TODO: Implement signInWithApple
      throw UnimplementedError('signInWithApple not implemented yet');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  @override
  Future<void> signInWithGitHub() async {
    try {
      final launched = await _authClient.signInWithOAuth(
        OAuthProvider.github,
        'com.yourcompany.authflowapp://callback',
      );
      print(launched);
      if (!launched) {
        throw ServerException('Failed to signIn with GitHub');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign in with GitHub: ${e.toString()}');
    }
  }
}
