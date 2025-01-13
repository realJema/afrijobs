import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Widget _buildProfileSection(String title, String? value, VoidCallback onEdit) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Not set',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _signOut,
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profile?['avatar_url'] != null
                        ? NetworkImage(_profile!['avatar_url'])
                        : null,
                    child: _profile?['avatar_url'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D4A3E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(
                      'Full Name',
                      _profile?['full_name'],
                      () {
                        // Show edit dialog
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Email',
                      _profile?['email'],
                      () {
                        // Show edit dialog
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Phone Number',
                      _profile?['phone_number'],
                      () {
                        // Show edit dialog
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Location',
                      _profile?['location'],
                      () {
                        // Show edit dialog
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resume Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_profile?['resume_url'] != null)
                      Row(
                        children: [
                          const Icon(Icons.description),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resume.pdf',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // Handle resume download
                            },
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle resume upload
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D4A3E),
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
