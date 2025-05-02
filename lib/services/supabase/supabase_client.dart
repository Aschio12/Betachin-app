import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton class that provides access to the Supabase client.
class SupabaseClient {
  final SupabaseClient _client;
  final _logger = Logger('SupabaseClient');

  SupabaseClient(this._client);

  SupabaseClient get client => _client;

  /// Refresh the authentication session to ensure the token is valid
  // Future<void> refreshSession() async {
  //   try {
  //     if (_client.auth.currentSession != null) {
  //       await _client.auth.refreshSession();
  //       _logger.info('Session refreshed successfully');
  //     } else {
  //       _logger.info('No session to refresh');
  //     }
  //   } catch (e) {
  //     _logger.severe('Error refreshing session: $e');
  //   }
  // }

  // /// Get the current user ID or throw an exception if not authenticated
  // String getCurrentUserId() {
  //   final userId = _client.auth.currentUser?.id;
  //   if (userId == null) {
  //     throw Exception('User not authenticated');
  //   }
  //   return userId;
  // }

  // /// Check if the user is authenticated
  // bool isAuthenticated() {
  //   return _client.auth.currentUser != null;
  // }
}
