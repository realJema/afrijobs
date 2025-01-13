import 'package:postgrest/postgrest.dart';

class JobFilters {
  final String? searchTerm;
  final String? type;
  final String? town;
  final String? region;
  final List<String> tags;
  final String? minSalary;
  final String? maxSalary;
  final String? dateRange;
  final String? minApplicants;
  final String? maxApplicants;

  JobFilters({
    this.searchTerm,
    this.type,
    this.town,
    this.region,
    this.minSalary,
    this.maxSalary,
    this.dateRange,
    this.minApplicants,
    this.maxApplicants,
    List<String>? tags,
  }) : tags = tags ?? [];

  JobFilters copyWith({
    String? searchTerm,
    String? type,
    String? town,
    String? region,
    List<String>? tags,
    String? minSalary,
    String? maxSalary,
    String? dateRange,
    String? minApplicants,
    String? maxApplicants,
  }) {
    return JobFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      type: type ?? this.type,
      town: town ?? this.town,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      dateRange: dateRange ?? this.dateRange,
      minApplicants: minApplicants ?? this.minApplicants,
      maxApplicants: maxApplicants ?? this.maxApplicants,
    );
  }

  PostgrestFilterBuilder<dynamic> applyFilters(PostgrestFilterBuilder<dynamic> query) {
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      query = query.or('title.ilike.%${searchTerm!}%,description.ilike.%${searchTerm!}%');
    }

    if (type != null && type!.isNotEmpty) {
      // Filter by job type using the job_types table
      query = query.eq('job_types.name', type).not('job_types', 'is', null);
    }

    if (town != null && town!.isNotEmpty) {
      query = query.eq('towns.name', town);
    }

    if (region != null && region!.isNotEmpty) {
      query = query.eq('towns.region', region);
    }

    if (tags.isNotEmpty) {
      // Filter jobs that have any of the selected tags
      query = query.contains('job_tags.tags.name', tags);
    }

    if (minSalary != null && minSalary!.isNotEmpty) {
      final minValue = int.tryParse(minSalary!);
      if (minValue != null) {
        query = query.gte('min_salary', minValue);
      }
    }

    if (maxSalary != null && maxSalary!.isNotEmpty) {
      final maxValue = int.tryParse(maxSalary!);
      if (maxValue != null) {
        query = query.lte('max_salary', maxValue);
      }
    }

    if (dateRange != null && dateRange!.isNotEmpty) {
      final now = DateTime.now().toUtc();
      DateTime? startDate;

      switch (dateRange) {
        case 'Last 24 hours':
          startDate = now.subtract(const Duration(hours: 24));
          break;
        case 'Last week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last 30 days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          break;
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
    }

    return query;
  }

  bool get hasFilters =>
      searchTerm != null ||
      type != null ||
      town != null ||
      region != null ||
      minSalary != null ||
      maxSalary != null ||
      dateRange != null ||
      minApplicants != null ||
      maxApplicants != null ||
      tags.isNotEmpty;

  int get filterCount {
    int count = 0;
    if (type != null) count++;
    if (town != null) count++;
    if (region != null) count++;
    if (minSalary != null || maxSalary != null) count++;
    if (tags.isNotEmpty) count++;
    if (dateRange != null) count++;
    if (minApplicants != null || maxApplicants != null) count++;
    return count;
  }

  bool get isEmpty =>
      searchTerm == null &&
      type == null &&
      town == null &&
      region == null &&
      tags.isEmpty &&
      minSalary == null &&
      maxSalary == null &&
      dateRange == null &&
      minApplicants == null &&
      maxApplicants == null;

  Map<String, dynamic> toJson() => {
        'searchTerm': searchTerm,
        'type': type,
        'town': town,
        'region': region,
        'tags': tags,
        'minSalary': minSalary,
        'maxSalary': maxSalary,
        'dateRange': dateRange,
        'minApplicants': minApplicants,
        'maxApplicants': maxApplicants,
      };
}
