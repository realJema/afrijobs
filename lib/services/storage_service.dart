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

      // Generate filename
      final fileExt = p.extension(pickedFile.path).toLowerCase();
      if (!_isValidImageExtension(fileExt)) {
        print('Invalid image format: $fileExt');
        return null;
      }

      final fileName = 'profile_$userId$fileExt';

      try {
        // Upload bytes to Supabase Storage
        await _supabase.storage.from('avatars').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

        // Get the public URL
        return _supabase.storage.from('avatars').getPublicUrl(fileName);
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
}
