class Job {
  final String id;
  final String title;
  final String company;
  final String? companyLogo;
  final String description;
  final String? type;
  final int? minSalary;
  final int? maxSalary;
  final List<String> tags;
  final String? requirements;
  final String? contact;
  final String? townName;
  final String? region;
  final int? applicants;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo,
    required this.description,
    this.type,
    this.minSalary,
    this.maxSalary,
    required this.tags,
    this.requirements,
    this.contact,
    this.townName,
    this.region,
    this.applicants,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      companyLogo: json['company_logo'] as String?,
      description: json['description'] as String,
      type: json['type'] as String?,
      minSalary: json['min_salary'] as int?,
      maxSalary: json['max_salary'] as int?,
      tags: List<String>.from(json['tags'] ?? []),
      requirements: json['requirements'] as String?,
      contact: json['contact'] as String?,
      townName: json['town_name'] as String?,
      region: json['region'] as String?,
      applicants: json['applicants'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'company_logo': companyLogo,
      'description': description,
      'type': type,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'tags': tags,
      'requirements': requirements,
      'contact': contact,
      'town_name': townName,
      'region': region,
      'applicants': applicants,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
