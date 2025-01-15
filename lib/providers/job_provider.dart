import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  Future<Map<String, dynamic>> applyForJob(String jobId, String applicationType) async {
    try {
      final response = await _supabase
          .rpc('apply_for_job', params: {
            'p_job_id': jobId,
            'p_user_id': _supabase.auth.currentUser!.id,
            'p_application_type': applicationType,
          });

      if (response != null) {
        notifyListeners(); // Notify listeners to update UI with new applicants count
      }

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
