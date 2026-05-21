import 'dart:io';

import 'package:auth_flow_app/core/network/supabase/storage_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageClientImpl extends StorageClient {
  final SupabaseStorageClient client;

  StorageClientImpl(this.client);

  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
    required FileOptions options
  }) async {
    return client.from(bucket).upload(path, file, fileOptions: options);
  }

  @override
  Future<String> getPublicUrl({
    required String bucket,
    required String path,
  }) async {
    return client.from(bucket).getPublicUrl(path);
  }
}
