import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient supabase;
  final _logger = Logger('UserService');

  UserService({required this.supabase});

  // Get user profile details
  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();

      return response;
    } catch (e) {
      _logger.severe('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String fullName,
    String? avatarUrl,
    String? phone,
    String? address,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await supabase.from('profiles').update({
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'phone': phone,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      _logger.severe('Error updating user profile: $e');
      rethrow;
    }
  }
}
