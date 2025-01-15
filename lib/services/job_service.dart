import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';
import '../models/job_filters.dart';
import '../models/town.dart';
import '../utils/error_handler.dart';

class JobService {
  final supabase = Supabase.instance.client;

  Future<List<Job>> getJobs({JobFilters? filters}) async {
    try {
      var query = supabase
          .from('jobs')
          .select('''
            *,
            companies (
              name,
              logo_url
            ),
            job_types (
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
            ),
            profiles (
              full_name,
              avatar_url,
              location
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
          
          // Handle company data
          if (job['companies'] != null) {
            jobData['company'] = job['companies']['name'];
            jobData['logo'] = job['companies']['logo_url'];
          }
          
          // Handle job type
          if (job['job_types'] != null) {
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

          // Handle profile
          if (job['profiles'] != null) {
            jobData['profile'] = job['profiles'];
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
            companies (
              name,
              logo_url
            ),
            job_types (
              name
            ),
            towns (
              name,
              region
            ),
            profiles (
              full_name,
              avatar_url,
              location
            )
          ''')
          .eq('id', id)
          .single();

      if (response == null) {
        print('Job not found');
        return null;
      }

      final jobData = Map<String, dynamic>.from(response);
      
      // Handle company data
      if (response['companies'] != null) {
        jobData['company'] = response['companies']['name'];
        jobData['logo'] = response['companies']['logo_url'];
      }
      
      // Handle job type
      if (response['job_types'] != null) {
        jobData['job_type'] = response['job_types']['name'];
      }
      
      // Handle location
      if (response['towns'] != null) {
        jobData['location'] = '${response['towns']['name']}, ${response['towns']['region']}';
      }
      
      // Handle profile
      if (response['profiles'] != null) {
        jobData['profile'] = response['profiles'];
      }
      
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
      
      // Call the simplified create_job function
      final result = await supabase.rpc('create_job', params: {
        'p_title': jobData['title'],
        'p_description': jobData['description'],
        'p_company_name': job.company,
        'p_requirements': jobData['requirements'],
        'p_contact_email': jobData['contact_email'],
        'p_contact_phone': jobData['contact_phone'],
        'p_min_salary': jobData['min_salary'] != null ? int.tryParse(jobData['min_salary']) : null,
        'p_max_salary': jobData['max_salary'] != null ? int.tryParse(jobData['max_salary']) : null,
        'p_town_id': jobData['town_id'],
        'p_status': jobData['status'],
        'p_application_deadline': jobData['application_deadline'],
        'p_tags': tags
      });

      if (result == null) {
        throw Exception('Failed to create job');
      }
    } catch (e) {
      print('Error creating job: $e');
      rethrow;
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
        // Update the job
        await supabase
            .from('jobs')
            .update(jobData)
            .eq('id', id);

        // Update job type if provided
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

        // Update tags
        if (tags.isNotEmpty) {
          // First remove existing tags
          await supabase
              .from('job_tags')
              .delete()
              .eq('job_id', id);

          // Then add new tags
          for (final tag in tags) {
            final tagResponse = await supabase
                .from('tags')
                .upsert({
                  'name': tag,
                  'created_at': DateTime.now().toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .select()
                .single();

            await supabase
                .from('job_tags')
                .insert({
                  'job_id': id,
                  'tag_id': tagResponse['id'],
                  'created_at': DateTime.now().toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                });
          }
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
      await supabase.rpc('begin_transaction');

      try {
        // Delete job tags first
        await supabase
            .from('job_tags')
            .delete()
            .eq('job_id', id);

        // Then delete the job
        await supabase
            .from('jobs')
            .delete()
            .eq('id', id);

        await supabase.rpc('commit_transaction');
      } catch (e) {
        await supabase.rpc('rollback_transaction');
        throw e;
      }
    } catch (e) {
      print('Error deleting job: $e');
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<List<Town>> getTowns() async {
    try {
      final response = await supabase
          .from('towns')
          .select('*')
          .order('name');

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((town) => Town.fromJson(Map<String, dynamic>.from(town)))
          .toList();
    } catch (e) {
      print('Error fetching towns: $e');
      return [];
    }
  }

  Future<Map<String, List<String>>> getTownsByRegion() async {
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

  Future<Map<String, dynamic>> applyForJob(String jobId, String applicationType) async {
    try {
      final response = await supabase
          .rpc('apply_for_job', params: {
            'p_job_id': jobId,
            'p_user_id': supabase.auth.currentUser!.id,
            'p_application_type': applicationType,
          });

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error applying for job: $e');
      return {
        'success': false,
        'message': 'Failed to apply for job. Please try again later.',
      };
    }
  }
}
