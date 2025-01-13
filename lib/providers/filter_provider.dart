import 'package:flutter/foundation.dart';
import '../models/job_filters.dart';
import '../services/job_service.dart'; // Assuming JobService is defined in this file

class FilterProvider with ChangeNotifier {
  JobFilters _filters = JobFilters();
  Map<String, List<String>> _townsByRegion = {};
  List<String> _jobTypes = [];
  List<String> _availableTags = [];
  bool _isInitialized = false;

  JobFilters get filters => _filters;
  Map<String, List<String>> get townsByRegion => _townsByRegion;
  List<String> get jobTypes => _jobTypes;
  List<String> get availableTags => _availableTags;
  bool get isInitialized => _isInitialized;

  final JobService _jobService = JobService();

  Future<void> initializeFilterData() async {
    if (_isInitialized) return;
    
    try {
      final towns = await _jobService.getTowns();
      final types = await _jobService.getJobTypes();
      final tags = await _jobService.getTags();

      _townsByRegion = towns;
      _jobTypes = types;
      _availableTags = tags;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing filter data: $e');
    }
  }

  void updateFilters(JobFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void clearFilter({
    bool searchTerm = false,
    bool type = false,
    bool town = false,
    bool region = false,
    bool tags = false,
    bool minSalary = false,
    bool maxSalary = false,
    bool dateRange = false,
  }) {
    JobFilters newFilters = _filters.copyWith(
      searchTerm: searchTerm ? null : _filters.searchTerm,
      type: type ? null : _filters.type,
      town: town ? null : _filters.town,
      region: region ? null : _filters.region,
      tags: tags ? [] : _filters.tags,
      minSalary: minSalary ? null : _filters.minSalary,
      maxSalary: maxSalary ? null : _filters.maxSalary,
      dateRange: dateRange ? null : _filters.dateRange,
    );
    updateFilters(newFilters);
  }

  void clearAllFilters() {
    _filters = JobFilters();
    notifyListeners();
  }
}
