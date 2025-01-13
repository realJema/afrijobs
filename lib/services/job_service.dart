import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';
import '../models/job_filters.dart';
import '../utils/error_handler.dart';

class JobService {
  final supabase = Supabase.instance.client;

  Future<List<Job>> getJobs({JobFilters? filters}) async {
    try {
      var query = supabase
          .from('jobs')
          .select('''
            *,
            towns!inner (
              name,
              region
            )
          ''');

      if (filters != null) {
        query = filters.applyFilters(query);
      }

      final response = await query.order('created_at', ascending: false).execute();
      
      return (response.data as List).map((job) {
        final town = job['towns'];
        return Job.fromJson({
          ...job,
          'town_name': town['name'],
          'region': town['region'],
        });
      }).toList();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Job> getJob(String id) async {
    try {
      final response = await supabase
          .from('jobs')
          .select('''
            *,
            towns!inner (
              name,
              region
            )
          ''')
          .eq('id', id)
          .single()
          .execute();

      final town = response.data['towns'];
      return Job.fromJson({
        ...response.data,
        'town_name': town['name'],
        'region': town['region'],
      });
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> createJob(Job job) async {
    try {
      await supabase
          .from('jobs')
          .insert(job.toJson())
          .execute();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> updateJob(String id, Job job) async {
    try {
      await supabase
          .from('jobs')
          .update(job.toJson())
          .eq('id', id)
          .execute();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      await supabase
          .from('jobs')
          .delete()
          .eq('id', id)
          .execute();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Map<String, List<String>>> getTowns() async {
    try {
      final response = await supabase
          .from('towns')
          .select('name, region')
          .order('region')
          .execute();
      
      final Map<String, List<String>> townsByRegion = {};
      for (final item in response.data) {
        final region = item['region'] as String;
        final town = item['name'] as String;
        townsByRegion.putIfAbsent(region, () => []).add(town);
      }
      return townsByRegion;
    } catch (e) {
      if (ErrorHandler.isNetworkError(e)) {
        throw Exception(ErrorHandler.getErrorMessage(e));
      }
      return {};
    }
  }
}
