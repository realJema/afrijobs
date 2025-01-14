import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://rsezkztlwlddijzffvkt.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzZXprenRsd2xkZGlqemZmdmt0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0MjU5NTEsImV4cCI6MjA1MjAwMTk1MX0.Yg_W5Fc63eH0YaMWLlcyOltXLezlNBvGfxC4CyNvreM';
  
  static final SupabaseClient supabaseClient = Supabase.instance.client;
}
