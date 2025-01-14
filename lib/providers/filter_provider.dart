import 'package:flutter/foundation.dart';
import '../models/job_filters.dart';
import '../models/town.dart';
import '../services/job_service.dart';

class FilterProvider with ChangeNotifier {
  JobFilters _filters = JobFilters();
  Map<String, List<String>> _townsByRegion = {};
  List<Town> _towns = [];
  List<String> _jobTypes = [];
  List<String> _availableTags = [];
  bool _isInitialized = false;

  JobFilters get filters => _filters;
  Map<String, List<String>> get townsByRegion => _townsByRegion;
  List<Town> get towns => _towns;
  List<String> get jobTypes => _jobTypes;
  List<String> get availableTags => _availableTags;
  bool get isInitialized => _isInitialized;

  final JobService _jobService = JobService();

  Future<void> initializeFilterData() async {
    if (_isInitialized) return;
    
    try {
      final fetchedTowns = await _jobService.getTowns();
      final types = await _jobService.getJobTypes();
      final tags = await _jobService.getTags();

      // Store the full Town objects
      _towns = fetchedTowns;

      // Organize towns by region for the filter UI
      _townsByRegion = _organizeTownsByRegion(fetchedTowns);
      
      _jobTypes = types;
      _availableTags = tags;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing filter data: $e');
    }
  }

  Map<String, List<String>> _organizeTownsByRegion(List<Town> towns) {
    final Map<String, List<String>> organized = {};
    
    for (final town in towns) {
      final region = town.region ?? 'Other';
      if (!organized.containsKey(region)) {
        organized[region] = [];
      }
      organized[region]!.add(town.name);
    }

    return organized;
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

  // Helper method to find a town by name
  Town? findTownByName(String name) {
    return _towns.firstWhere(
      (town) => town.name == name,
      orElse: () => null as Town,
    );
  }
}
