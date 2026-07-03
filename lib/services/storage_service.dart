import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

class StorageService {
  static const _propertyMediaBucket = 'property-media';

  Future<List<String>> uploadPropertyImages(List<PlatformFile> files) async {
    if (files.isEmpty) {
      return ['https://images.unsplash.com/photo-1564013799919-ab600027ffc6'];
    }

    return _uploadPropertyMedia(
      files: files,
      folder: 'property-images',
      fallbackPrefix: 'local-property-image',
    );
  }

  Future<List<String>> uploadPropertyVideos(List<PlatformFile> files) async {
    if (files.isEmpty) return [];

    return _uploadPropertyMedia(
      files: files,
      folder: 'property-videos',
      fallbackPrefix: 'local-property-video',
    );
  }

  Future<List<String>> _uploadPropertyMedia({
    required List<PlatformFile> files,
    required String folder,
    required String fallbackPrefix,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return files
          .map((file) => '$fallbackPrefix://${_safeFileName(file.name)}')
          .toList();
    }

    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const StorageException(
        'Sign in before uploading property media.',
        statusCode: '401',
        error: 'Unauthorized',
      );
    }

    final storage = client.storage.from(_propertyMediaBucket);
    final urls = <String>[];

    for (final file in files) {
      final bytes = await file.readAsBytes();
      final path =
          '$userId/$folder/${DateTime.now().microsecondsSinceEpoch}_'
          '${_safeFileName(file.name)}';
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: _contentType(file.name)),
      );
      urls.add(storage.getPublicUrl(path));
    }

    return urls;
  }

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  String _contentType(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'webm' => 'video/webm',
      _ => 'application/octet-stream',
    };
  }
}
