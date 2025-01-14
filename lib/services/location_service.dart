import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class LocationService {
  final SupabaseClient _supabase = SupabaseConfig.supabaseClient;

  Future<List<String>> getTowns() async {
    try {
      final response = await _supabase
          .from('towns')
          .select('name')
          .order('name');

      return (response as List).map((town) => town['name'] as String).toList();
    } catch (e) {
      // Return some default towns in case of error
      return [
        'Lagos',
        'Abuja',
        'Port Harcourt',
        'Kano',
        'Ibadan',
        'Kaduna',
        'Enugu',
        'Benin City',
        'Calabar',
        'Warri'
      ];
    }
  }
}
