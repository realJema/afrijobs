import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    context.read<ProfileProvider>().clear();
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
    final profile = context.watch<ProfileProvider>().profile;

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
                    backgroundImage: profile?['avatar_url'] != null
                        ? NetworkImage(profile!['avatar_url'])
                        : null,
                    child: profile?['avatar_url'] == null
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
                      profile?['full_name'],
                      () async {
                        // Show edit dialog
                        final provider = context.read<ProfileProvider>();
                        await provider.updateProfile(
                          fullName: 'New Name', // Replace with dialog input
                        );
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Email',
                      profile?['email'],
                      () {
                        // Email cannot be edited
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Phone Number',
                      profile?['phone_number'],
                      () async {
                        // Show edit dialog
                        final provider = context.read<ProfileProvider>();
                        await provider.updateProfile(
                          phoneNumber: 'New Phone', // Replace with dialog input
                        );
                      },
                    ),
                    const Divider(),
                    _buildProfileSection(
                      'Location',
                      profile?['location'],
                      () async {
                        // Show edit dialog
                        final provider = context.read<ProfileProvider>();
                        await provider.updateProfile(
                          location: 'New Location', // Replace with dialog input
                        );
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
                    if (profile?['resume_url'] != null)
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
                        onPressed: () async {
                          // Handle resume upload
                          final provider = context.read<ProfileProvider>();
                          await provider.updateProfile(
                            resumeUrl: 'new_resume_url', // Replace with actual upload
                          );
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
