import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;
    
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return response as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    String? location,
    String? bio,
    String? resumeUrl,
  }) async {
    if (!isAuthenticated) return;

    final updates = {
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (location != null) 'location': location,
      if (bio != null) 'bio': bio,
      if (resumeUrl != null) 'resume_url': resumeUrl,
    };

    await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', currentUser!.id);
  }
}
