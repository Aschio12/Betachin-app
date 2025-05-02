// import 'package:logging/logging.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'supabase_client.dart';

// class AuthService {
//   // final SupabaseClient _supabaseClient;
//   final _logger = Logger('AuthService');

//   AuthService(this._supabaseClient);

//   /// Refresh the authentication session to ensure the token is valid
//   Future<void> refreshSession() async {
//     await _supabaseClient.refreshSession();
//   }

//   /// Get the current user ID or throw an exception if not authenticated
//   String getCurrentUserId() {
//     return _supabaseClient.getCurrentUserId();
//   }

//   /// Check if the user is authenticated
//   bool isAuthenticated() {
//     return _supabaseClient.isAuthenticated();
//   }

//   /// Sign out the current user
//   Future<void> signOut() async {
//     try {
//       await _supabaseClient.client.auth.signOut();
//       _logger.info('User signed out successfully');
//     } catch (e) {
//       _logger.severe('Error signing out: $e');
//       rethrow;
//     }
//   }
// }
