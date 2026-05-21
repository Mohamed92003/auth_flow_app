import 'package:auth_flow_app/features/auth/data/models/user_model.dart';

abstract class ProfileDataSource {
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  Future<String> uploadProfilePicture({required String filePath});

  Future<void> deleteAccount();
  
}