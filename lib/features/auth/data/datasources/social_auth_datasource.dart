import 'package:auth_flow_app/features/auth/data/models/user_model.dart';

abstract class SocialAuthDataSource {
  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithApple();

  Future<void> signInWithGitHub();
}