import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../utils/currency_formatter.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  Job get job => widget.job;

  @override
  Widget build(BuildContext context) {
    debugPrint('Building JobDetailsScreen for job: ${job.id}');
    debugPrint('Job avatar URL: ${job.avatarUrl}');
    debugPrint('Job company logo: ${job.logo}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Company Logo or Profile Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: job.avatarUrl != null
                          ? Image.network(
                              job.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error loading avatar: $error');
                                debugPrint('Stacktrace: $stackTrace');
                                return job.logo != null && job.logo!.isNotEmpty
                                    ? Image.network(
                                        job.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint('Error loading logo: $error');
                                          return const Icon(Icons.business, size: 40, color: Colors.grey);
                                        },
                                      )
                                    : const Icon(Icons.business, size: 40, color: Colors.grey);
                              },
                            )
                          : (job.logo != null && job.logo!.isNotEmpty
                              ? Image.network(
                                  job.logo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading logo: $error');
                                    return const Icon(Icons.business, size: 40, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.business, size: 40, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    job.company ?? job.userFullName ?? 'Anonymous',
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
          ],
        ),
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
                onPressed: () => _showApplyOptions(context),
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

  void _showApplyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How would you like to apply?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Call directly'),
                subtitle: Text(job.contactPhone ?? 'No phone number available'),
                enabled: job.contactPhone != null,
                onTap: () async {
                  Navigator.pop(context);
                  if (job.contactPhone != null) {
                    debugPrint('Applying for job ${job.id} via phone');
                    final result = await context.read<JobProvider>().applyForJob(job.id, 'phone');
                    debugPrint('Application result: $result');
                    if (mounted && !result['already_applied']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: result['success'] ? Colors.green : Colors.red,
                        ),
                      );
                    }
                    if (result['success']) {
                      final url = 'tel:${job.contactPhone}';
                      debugPrint('Launching phone URL: $url');
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        debugPrint('Could not launch phone URL');
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Send email'),
                subtitle: Text(job.contactEmail ?? 'No email available'),
                enabled: job.contactEmail != null,
                onTap: () async {
                  Navigator.pop(context);
                  if (job.contactEmail != null) {
                    debugPrint('Applying for job ${job.id} via email');
                    final result = await context.read<JobProvider>().applyForJob(job.id, 'email');
                    debugPrint('Application result: $result');
                    if (mounted && !result['already_applied']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: result['success'] ? Colors.green : Colors.red,
                        ),
                      );
                    }
                    if (result['success']) {
                      final url = 'mailto:${job.contactEmail}?subject=Application for ${job.title}';
                      debugPrint('Launching email URL: $url');
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        debugPrint('Could not launch email URL');
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.message,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Send message'),
                subtitle: const Text('Chat with the employer'),
                onTap: () async {
                  Navigator.pop(context);
                  debugPrint('Applying for job ${job.id} via chat');
                  final result = await context.read<JobProvider>().applyForJob(job.id, 'chat');
                  debugPrint('Application result: $result');
                  if (mounted && !result['already_applied']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                  if (result['success']) {
                    debugPrint('Chat application successful, would navigate to chat screen');
                    // TODO: Navigate to chat screen
                    // Navigator.pushNamed(context, '/chat', arguments: job.userId);
                  }
                },
              ),
            ],
          ),
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
