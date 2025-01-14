class Job {
  final String id;
  final String title;
  final String? companyId;
  final String? company;
  final String? logo;
  final String? townId;  // Add townId
  final String location; // Keep location for display purposes
  final String description;
  final String? type;
  final List<String> tags;
  final String? minSalary;
  final String? maxSalary;
  final int? applicants;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? contactEmail;
  final String? contactPhone;
  final String? requirements;
  final String status;
  final DateTime? deadline;
  final Map<String, dynamic>? profile;

  Job({
    required this.id,
    required this.title,
    this.companyId,
    this.company,
    this.logo,
    this.townId,
    required this.location,
    required this.description,
    this.type,
    List<String>? tags,
    this.minSalary,
    this.maxSalary,
    this.applicants,
    required this.createdAt,
    DateTime? updatedAt,
    this.contactEmail,
    this.contactPhone,
    this.requirements,
    this.status = 'active',
    this.deadline,
    this.profile,
  }) : tags = tags ?? [],
       updatedAt = updatedAt ?? createdAt;

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      companyId: json['company_id'] as String?,
      company: json['company_name'] as String?,
      logo: json['logo_url'] as String?,
      townId: json['town_id'] as String?,
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['job_types']?['name'] as String?,
      tags: (json['tag_names'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      minSalary: json['min_salary']?.toString(),
      maxSalary: json['max_salary']?.toString(),
      applicants: json['applicants'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      requirements: json['requirements'] as String?,
      status: json['status'] as String? ?? 'active',
      deadline: json['application_deadline'] != null ? DateTime.parse(json['application_deadline']) : null,
      profile: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_id': companyId,
      'company': company,
      'logo': logo,
      'town_id': townId,
      'location': location,
      'description': description,
      'type': type,
      'tags': tags,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'applicants': applicants,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'requirements': requirements,
      'status': status,
      'application_deadline': deadline?.toIso8601String(),
      'profile': profile,
    };
  }

  String? get avatarUrl => profile?['avatar_url'] as String?;
  String? get userFullName => profile?['full_name'] as String?;
  String? get userLocation => profile?['location'] as String?;
}
