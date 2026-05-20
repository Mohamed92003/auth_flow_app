import 'package:auth_flow_app/features/auth/data/models/user_model.dart';

abstract class SessionDataSource {
  UserModel? getCurrentUser();

  Future<void> signOut();

  Stream<UserModel?> get authStateChanges;
}