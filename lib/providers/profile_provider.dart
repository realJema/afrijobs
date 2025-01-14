import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _authService.getCurrentUserProfile();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    String? location,
    String? bio,
    String? resumeUrl,
  }) async {
    try {
      await _authService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        location: location,
        bio: bio,
        resumeUrl: resumeUrl,
      );
      await loadProfile(); // Reload profile after update
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
