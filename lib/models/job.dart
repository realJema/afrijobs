class Job {
  final int id;
  final String title;
  final String companyName;
  final String? logoUrl;
  final String location;
  final String salary;
  final String type;
  final int applicants;
  final List<String> tags;
  final String description;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    this.logoUrl,
    required this.location,
    required this.salary,
    required this.type,
    required this.applicants,
    required this.tags,
    required this.description,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      companyName: json['company_name'] as String,
      logoUrl: json['logo_url'] as String?,
      location: json['location'] as String,
      salary: json['salary'] as String,
      type: json['type'] as String,
      applicants: json['applicants'] as int,
      tags: List<String>.from(json['tags']),
      description: json['description'] as String,
    );
  }
}
