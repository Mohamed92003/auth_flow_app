import 'dart:io';

import 'package:auth_flow_app/core/error/exceptions.dart';
import 'package:auth_flow_app/core/network/supabase/auth_client.dart';
import 'package:auth_flow_app/core/network/supabase/storage_client.dart';
import 'package:auth_flow_app/features/auth/data/datasources/profile_datasource.dart';
import 'package:auth_flow_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class ProfileDataSourceImpl implements ProfileDataSource {
  final AuthClient _authClient;
  final StorageClient _storageClient;
  ProfileDataSourceImpl(this._authClient, this._storageClient);

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final currentMetaData = _authClient.currentUser?.userMetadata;

      final updateMetaData = {
        ...currentMetaData ?? {},
        'name': ?displayName,
        'custom_avatar_url': ?photoUrl,
      };

      final response = await _authClient.updateUser(
        UserAttributes(data: updateMetaData),
      );

      if (response.user == null) {
        throw ServerException('Failed to update profile: User is null');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
Future<String> uploadProfilePicture({required String filePath}) async {
  try {
    final userId = _authClient.currentUser?.id;
    final fileExt = filePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uploadPath = '$userId/avatar_$timestamp.$fileExt'; // ✅ unique name

    await _storageClient.uploadFile(
      bucket: 'avatars',
      path: uploadPath,
      file: File(filePath),
      options: const FileOptions(upsert: false), // ✅ no need for upsert now
    );

    final url = await _storageClient.getPublicUrl(
      bucket: 'avatars',
      path: uploadPath,
    );

    await _authClient.updateUser(
      UserAttributes(
        data: {
          ..._authClient.currentUser?.userMetadata ?? {},
          'custom_avatar_url': url,
        },
      ),
    );
    return url;
  } catch (e) {
    throw ServerException('Failed to upload profile picture: ${e.toString()}');
  }
}
  @override
  Future<void> deleteAccount() async {
    try {
      await _authClient.deleteAccount();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete account: ${e.toString()}');
    }
  }
}
