import 'package:supabase_flutter/supabase_flutter.dart';

class FilterService {
  final SupabaseClient supabase;
  static FilterService? _instance;

  // Cache for filter data
  List<String> _jobTypes = [];
  List<String> _towns = [];
  List<String> _tags = [];
  bool _isInitialized = false;

  FilterService._({required this.supabase});

  static FilterService get instance {
    _instance ??= FilterService._(supabase: Supabase.instance.client);
    return _instance!;
  }

  bool get isInitialized => _isInitialized;
  List<String> get jobTypes => _jobTypes;
  List<String> get towns => _towns;
  List<String> get tags => _tags;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Future.wait([
        _loadJobTypes(),
        _loadTowns(),
        _loadTags(),
      ]);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing FilterService: $e');
      rethrow;
    }
  }

  Future<void> _loadJobTypes() async {
    try {
      final response = await supabase
          .from('job_types')
          .select('name')
          .order('name');
      
      _jobTypes = (response as List)
          .map((type) => type['name'] as String)
          .toList();
    } catch (e) {
      print('Error loading job types: $e');
      _jobTypes = [];
    }
  }

  Future<void> _loadTowns() async {
    try {
      final response = await supabase
          .from('towns')
          .select('name')
          .order('name');
      
      _towns = (response as List)
          .map((town) => town['name'] as String)
          .toList();
    } catch (e) {
      print('Error loading towns: $e');
      _towns = [];
    }
  }

  Future<void> _loadTags() async {
    try {
      final response = await supabase
          .from('tags')
          .select('name')
          .order('name');
      
      _tags = (response as List)
          .map((tag) => tag['name'] as String)
          .toList();
    } catch (e) {
      print('Error loading tags: $e');
      _tags = [];
    }
  }

  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }
}
