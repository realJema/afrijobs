import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  Future<String?> uploadProfileImage(String userId, ImageSource source) async {
    try {
      // Request permission and pick image
      final XFile? pickedFile;
      try {
        pickedFile = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.front,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
      } on PlatformException catch (e) {
        print('Failed to pick image: $e');
        return null;
      }

      if (pickedFile == null) {
        print('No image selected');
        return null;
      }

      // Read file bytes
      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) {
        print('Empty image file');
        return null;
      }

      // Generate filename with timestamp to avoid conflicts
      final fileExt = p.extension(pickedFile.path).toLowerCase();
      if (!_isValidImageExtension(fileExt)) {
        print('Invalid image format: $fileExt');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_${userId}_$timestamp$fileExt';

      try {
        // Ensure user is authenticated
        final user = _supabase.auth.currentUser;
        if (user == null || user.id != userId) {
          print('User not authenticated or ID mismatch');
          return null;
        }

        // Upload bytes to Supabase Storage
        await _supabase.storage.from('avatars').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _getContentType(fileExt),
          ),
        );

        // Get the public URL
        final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
        print('Successfully uploaded image: $publicUrl');
        return publicUrl;
      } on StorageException catch (e) {
        print('Storage error: ${e.message}, Status: ${e.statusCode}, Error: ${e.error}');
        return null;
      } catch (e) {
        print('Error uploading to Supabase: $e');
        return null;
      }
    } catch (e) {
      print('Error in uploadProfileImage: $e');
      return null;
    }
  }

  bool _isValidImageExtension(String ext) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    return validExtensions.contains(ext.toLowerCase());
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
