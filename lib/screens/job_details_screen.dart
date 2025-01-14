import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';
import '../utils/currency_formatter.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with green gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D4A3E), Color(0xFF1A2E26)],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        job.company ?? 'Unknown Company',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        // Company Logo
                        Transform.translate(
                          offset: const Offset(0, -32),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: job.logo != null && job.logo!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        job.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.business, size: 40, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.business, size: 40, color: Colors.grey),
                            ),
                          ),
                        ),

                        // Job Info
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${job.company ?? 'Unknown Company'} • ${job.location}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                // Info Pills
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildInfoPill(
                                      Icons.attach_money, 
                                      CurrencyFormatter.formatSalaryRange(job.minSalary, job.maxSalary), 
                                      Colors.green.withOpacity(0.1), 
                                      Colors.green
                                    ),
                                    const SizedBox(width: 12),
                                    _buildInfoPill(Icons.work_outline, job.type ?? 'Full-time', Colors.orange.withOpacity(0.1), Colors.orange),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Job Details
                                const Text(
                                  'Job Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "We're looking for a Junior front-end developer works on building the user interface of a mobile application or website. They showcase their skills with the application's visual elements, including graphics, typography, and layouts. They also collaborate with back-end developers to ensure the app and users...",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Requirements
                                const Text(
                                  'Requirements',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "• Bachelor's degree in Computer Science or related field\n"
                                  "• 1-2 years of experience in front-end development\n"
                                  "• Proficiency in HTML, CSS, and JavaScript\n"
                                  "• Experience with modern front-end frameworks (React, Vue, or Angular)\n"
                                  "• Strong understanding of responsive design principles\n"
                                  "• Excellent problem-solving skills\n"
                                  "• Good communication and teamwork abilities",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Applicants
                                Row(
                                  children: [
                                    Text(
                                      'Applicants',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${job.applicants ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Skills
                                if (job.tags.isNotEmpty) ...[
                                  Text(
                                    'Skills',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final tag in ['Remote', 'Fulltime', 'Senior', 'Front End'])
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${job.applicants ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showContactOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4A3E),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch the app')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    await _launchUrl(phoneUri.toString(), context);
  }

  Future<void> _sendEmail(String email, String subject, BuildContext context) async {
    final message = 
        'I wish to apply for the ${job.title} position at ${job.company ?? 'your company'} that I found on AfriJobs.\n\n'
        'Please find my application attached.\n\n'
        'Best regards.';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': Uri.encodeComponent(subject),
        'body': Uri.encodeComponent(message),
      },
    );
    await _launchUrl(emailUri.toString(), context);
  }

  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final message = '''Hello, I wish to apply for the ${job.title} position at ${job.company ?? 'your company'} that I found on AfriJobs.''';
    final encodedMessage = Uri.encodeComponent(message);
    await _launchUrl('https://wa.me/$cleanPhone?text=$encodedMessage', context);
  }

  Future<void> _showContactOptions(BuildContext context) async {
    final contactEmail = job.contactEmail;
    final contactPhone = job.contactPhone;

    if (contactEmail == null && contactPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact information available')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (contactPhone != null && contactPhone.isNotEmpty) ...[
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2D4A3E),
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                  title: const Text('Call'),
                  subtitle: Text(contactPhone),
                  onTap: () {
                    Navigator.pop(context);
                    _makePhoneCall(contactPhone, context);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF25D366),
                    child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                  ),
                  title: const Text('WhatsApp'),
                  subtitle: Text(contactPhone),
                  onTap: () {
                    Navigator.pop(context);
                    _openWhatsApp(contactPhone, context);
                  },
                ),
              ],
              if (contactEmail != null && contactEmail.isNotEmpty)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4285F4),
                    child: Icon(Icons.email, color: Colors.white),
                  ),
                  title: const Text('Email'),
                  subtitle: Text(contactEmail),
                  onTap: () {
                    Navigator.pop(context);
                    _sendEmail(
                      contactEmail,
                      'Job Application: ${job.title}',
                      context,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
