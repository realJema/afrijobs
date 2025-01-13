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
            job_types!inner (
              name
            ),
            towns (
              name,
              region
            ),
            job_tags (
              tags (
                name
              )
            )
          ''');

      if (filters != null) {
        query = filters.applyFilters(query);
      }

      final response = await query.order('created_at', ascending: false);
      print('Job response: $response'); // Debug log
      
      if (response == null) {
        print('Response is null');
        return [];
      }

      if (response is! List) {
        print('Response is not a list: ${response.runtimeType}');
        return [];
      }

      return response.map((job) {
        try {
          final jobData = Map<String, dynamic>.from(job);
          
          // Handle job type
          if (job['job_types'] != null) {
            print('Job type data: ${job['job_types']}'); // Debug log
            jobData['job_types'] = job['job_types'];
          }
          
          // Handle location
          if (job['towns'] != null) {
            final townName = job['towns']['name'];
            final regionName = job['towns']['region'];
            jobData['location'] = '$townName${regionName != null ? ', $regionName' : ''}';
          }
          
          // Handle tags
          if (job['job_tags'] != null && job['job_tags'] is List) {
            jobData['tag_names'] = (job['job_tags'] as List)
                .where((tag) => tag['tags'] != null)
                .map((tag) => tag['tags']['name'] as String)
                .toList();
          } else {
            jobData['tag_names'] = [];
          }

          return Job.fromJson(jobData);
        } catch (e) {
          print('Error parsing job: $e');
          print('Job data: $job');
          return null;
        }
      }).whereType<Job>().toList();
    } catch (e) {
      print('Error fetching jobs: $e');
      rethrow;
    }
  }

  Future<Job?> getJob(String id) async {
    try {
      final response = await supabase
          .from('jobs')
          .select('''
            *,
            job_types!inner (
              name
            ),
            towns!inner (
              name,
              region
            )
          ''')
          .eq('id', id)
          .single();

      if (response == null) {
        print('Job not found');
        return null;
      }

      // Combine the job data with the joined tables
      final jobData = Map<String, dynamic>.from(response);
      jobData['job_type'] = response['job_types']['name'];
      jobData['location'] = '${response['towns']['name']}, ${response['towns']['region']}';
      return Job.fromJson(jobData);
    } catch (e) {
      print('Error fetching job: $e');
      return null;
    }
  }

  Future<void> createJob(Job job) async {
    try {
      final jobData = job.toJson();
      final tags = List<String>.from(jobData['tag_names'] ?? []);
      
      jobData.remove('tag_names');
      final jobType = jobData.remove('job_type');

      await supabase.rpc('begin_transaction');

      try {
        final jobResponse = await supabase
            .from('jobs')
            .insert(jobData)
            .select()
            .single();

        if (jobType != null) {
          final typeResponse = await supabase
              .from('job_types')
              .select('id')
              .eq('name', jobType)
              .single();

          await supabase
              .from('jobs')
              .update({'job_type_id': typeResponse['id']})
              .eq('id', jobResponse['id']);
        }

        if (tags.isNotEmpty) {
          await supabase.rpc('add_job_tags', params: {
            'p_job_id': jobResponse['id'],
            'p_tag_names': tags,
          });
        }

        await supabase.rpc('commit_transaction');
      } catch (e) {
        await supabase.rpc('rollback_transaction');
        throw e;
      }
    } catch (e) {
      print('Error creating job: $e'); 
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> updateJob(String id, Job job) async {
    try {
      final jobData = job.toJson();
      final tags = List<String>.from(jobData['tag_names'] ?? []);
      
      jobData.remove('tag_names');
      final jobType = jobData.remove('job_type');

      await supabase.rpc('begin_transaction');

      try {
        await supabase
            .from('jobs')
            .update(jobData)
            .eq('id', id);

        if (jobType != null) {
          final typeResponse = await supabase
              .from('job_types')
              .select('id')
              .eq('name', jobType)
              .single();

          await supabase
              .from('jobs')
              .update({'job_type_id': typeResponse['id']})
              .eq('id', id);
        }

        if (tags.isNotEmpty) {
          await supabase.rpc('add_job_tags', params: {
            'p_job_id': id,
            'p_tag_names': tags,
          });
        }

        await supabase.rpc('commit_transaction');
      } catch (e) {
        await supabase.rpc('rollback_transaction');
        throw e;
      }
    } catch (e) {
      print('Error updating job: $e'); 
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      await supabase
          .from('jobs')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting job: $e'); 
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Map<String, List<String>>> getTowns() async {
    try {
      final response = await supabase
          .from('towns')
          .select('name, region')
          .order('name');

      final Map<String, List<String>> townsByRegion = {};
      for (final town in response as List) {
        final region = town['region'] as String;
        final name = town['name'] as String;
        townsByRegion.putIfAbsent(region, () => []).add(name);
      }
      return townsByRegion;
    } catch (e) {
      print('Error fetching towns: $e'); 
      return {};
    }
  }

  Future<List<String>> getJobTypes() async {
    try {
      final response = await supabase
          .from('job_types')
          .select('name')
          .order('name');
      
      return (response as List).map((type) => type['name'] as String).toList();
    } catch (e) {
      print('Error fetching job types: $e'); 
      return [];
    }
  }

  Future<List<String>> getTags() async {
    try {
      final response = await supabase
          .from('tags')
          .select('name')
          .order('name');
      
      return (response as List).map((tag) => tag['name'] as String).toList();
    } catch (e) {
      print('Error fetching tags: $e'); 
      return [];
    }
  }
}
