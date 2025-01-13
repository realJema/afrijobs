import 'package:postgrest/postgrest.dart';

class JobFilters {
  final String? searchTerm;
  final String? type;
  final String? town;
  final String? region;
  final List<String> tags;
  final String? minSalary;
  final String? maxSalary;

  JobFilters({
    this.searchTerm,
    this.type,
    this.town,
    this.region,
    this.minSalary,
    this.maxSalary,
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
  }) {
    return JobFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      type: type ?? this.type,
      town: town ?? this.town,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
    );
  }

  PostgrestFilterBuilder applyFilters(PostgrestFilterBuilder query) {
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      query = query.or('title.ilike.%$searchTerm%,description.ilike.%$searchTerm%,company.ilike.%$searchTerm%');
    }

    if (type != null && type!.isNotEmpty) {
      query = query.eq('type', type);
    }

    if (town != null && town!.isNotEmpty) {
      query = query.eq('town_id.name', town);
    }

    if (region != null && region!.isNotEmpty) {
      query = query.eq('town_id.region', region);
    }

    if (tags.isNotEmpty) {
      query = query.contains('tags', tags);
    }

    if (minSalary != null && minSalary!.isNotEmpty) {
      query = query.gte('salary_range', minSalary);
    }

    if (maxSalary != null && maxSalary!.isNotEmpty) {
      query = query.lte('salary_range', maxSalary);
    }

    return query;
  }

  bool get isNotEmpty {
    return searchTerm != null ||
        type != null ||
        town != null ||
        region != null ||
        minSalary != null ||
        maxSalary != null ||
        tags.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (type != null) count++;
    if (town != null) count++;
    if (region != null) count++;
    if (minSalary != null || maxSalary != null) count++;
    if (tags.isNotEmpty) count++;
    return count;
  }
}
