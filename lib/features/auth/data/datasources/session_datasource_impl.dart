import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/features/auth/data/datasources/session_datasource.dart';
import 'package:auth_flow_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class SessionDataSourceImpl implements SessionDataSource {
  final AuthClient _authClient;

  SessionDataSourceImpl(this._authClient);

  @override
  UserModel? getCurrentUser()  {
    try {
     final user = _authClient.currentUser;
     return user != null ? UserModel.fromSupabaseUser(user) : null;
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authClient.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _authClient.authStateChanges.map((authState) {
     final User? user = authState.session?.user;
     return user != null ? UserModel.fromSupabaseUser(user) : null;
    });
  }
}
