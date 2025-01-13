class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String? type;
  final List<String> tags;
  final String? minSalary;
  final String? maxSalary;
  final int? applicants;
  final DateTime createdAt;
  final String? logo;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.type,
    List<String>? tags,
    this.minSalary,
    this.maxSalary,
    this.applicants,
    required this.createdAt,
    this.logo,
  }) : tags = tags ?? [];

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['job_types']?['name'] as String?,
      tags: (json['tag_names'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      minSalary: json['min_salary']?.toString(),
      maxSalary: json['max_salary']?.toString(),
      applicants: json['applicants'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      logo: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'job_type_id': null,
      'tag_names': tags,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'applicants': applicants,
      'created_at': createdAt.toIso8601String(),
      'logo': logo,
    };
  }
}
