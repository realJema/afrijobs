import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import '../models/job_filters.dart';

class JobService {
  static String get baseUrl {
    // 10.0.2.2 is the special IP for localhost on Android emulator
    return 'http://10.0.2.2:3000/api';
  }

  Future<List<Job>> getJobs({JobFilters? filters}) async {
    try {
      final queryParams = filters?.toQueryParameters() ?? {};
      final uri = Uri.parse('$baseUrl/jobs').replace(queryParameters: queryParams);
      
      print('Fetching jobs from: $uri');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return (data['data'] as List).map((jobData) => Job.fromJson(jobData)).toList();
        }
      }
      throw Exception('Failed to load jobs: Status ${response.statusCode}');
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception('Failed to load jobs: $e');
    }
  }

  Future<List<String>> getJobTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/types'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return List<String>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching job types: $e');
      return [];
    }
  }

  Future<List<String>> getTags() async {
    final response = await http.get(Uri.parse('$baseUrl/jobs/tags'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    }
    throw Exception('Failed to load tags');
  }

  Future<Map<String, List<String>>> getTowns() async {
    final response = await http.get(Uri.parse('$baseUrl/jobs/towns'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<String, List<String>> townsByRegion = {};
      
      for (final item in data) {
        final region = item['region'] as String;
        final town = item['name'] as String;
        
        if (!townsByRegion.containsKey(region)) {
          townsByRegion[region] = [];
        }
        townsByRegion[region]!.add(town);
      }
      
      return townsByRegion;
    }
    throw Exception('Failed to load towns');
  }

  Future<Job> getJob(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$id'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return Job.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load job: Status ${response.statusCode}');
    } catch (e) {
      print('Error fetching job: $e');
      throw Exception('Failed to load job: $e');
    }
  }
}
