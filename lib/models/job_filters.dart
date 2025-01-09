class JobFilters {
  final String? search;
  final String? type;
  final String? location;
  final int? minSalary;
  final int? maxSalary;
  final List<String> tags;

  JobFilters({
    this.search,
    this.type,
    this.location,
    this.minSalary,
    this.maxSalary,
    List<String>? tags,
  }) : tags = tags ?? [];

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};

    if (search != null && search!.isNotEmpty) {
      params['search'] = search!;
    }

    if (type != null) {
      params['type'] = type!;
    }

    if (location != null && location!.isNotEmpty) {
      params['location'] = location!;
    }

    if (minSalary != null) {
      params['minSalary'] = minSalary!.toString();
    }

    if (maxSalary != null) {
      params['maxSalary'] = maxSalary!.toString();
    }

    if (tags.isNotEmpty) {
      params['tags'] = tags.join(',');
    }

    return params;
  }

  bool get isNotEmpty {
    return search != null ||
        type != null ||
        location != null ||
        minSalary != null ||
        maxSalary != null ||
        tags.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (type != null) count++;
    if (location != null) count++;
    if (minSalary != null || maxSalary != null) count++;
    if (tags.isNotEmpty) count++;
    return count;
  }
}
