import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<List<String>> uploadPropertyImages(List<PlatformFile> files) async {
    if (files.isEmpty) {
      return ['https://images.unsplash.com/photo-1564013799919-ab600027ffc6'];
    }

    return _uploadPropertyMedia(
      files: files,
      folder: 'property-images',
      fallbackPrefix: 'firebase-storage://property-images',
    );
  }

  Future<List<String>> uploadPropertyVideos(List<PlatformFile> files) async {
    if (files.isEmpty) return [];

    return _uploadPropertyMedia(
      files: files,
      folder: 'property-videos',
      fallbackPrefix: 'firebase-storage://property-videos',
    );
  }

  Future<List<String>> _uploadPropertyMedia({
    required List<PlatformFile> files,
    required String folder,
    required String fallbackPrefix,
  }) async {
    if (Firebase.apps.isEmpty) {
      return files
          .map((file) => '$fallbackPrefix/${file.name.hashCode}')
          .toList();
    }

    final storage = FirebaseStorage.instance;
    final urls = <String>[];

    for (final file in files) {
      final bytes = await file.readAsBytes();
      final path =
          '$folder/${DateTime.now().microsecondsSinceEpoch}_'
          '${_safeFileName(file.name)}';
      final metadata = SettableMetadata(contentType: _contentType(file.name));
      final snapshot = await storage.ref(path).putData(bytes, metadata);
      urls.add(await snapshot.ref.getDownloadURL());
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
