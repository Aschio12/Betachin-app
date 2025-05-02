import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Main Supabase service that provides access to specialized services
class SupabaseService {
  // final SupabaseClient supabase;
  final _logger = Logger('SupabaseService');
  
  // late PropertyService propertyService;
  // late FavoritesService favoritesService;
  // late UserService userService;
  // late StorageService storageService;

  // SupabaseService({required this.supabase}) {
  //   storageService = StorageService(supabase: supabase);
  //   propertyService = PropertyService(supabase: supabase, storageService: storageService);
  //   favoritesService = FavoritesService(supabase: supabase);
  //   userService = UserService(supabase: supabase);
  // }

  // Refresh the authentication session to ensure the token is valid
  // Future<void> refreshSession() async {
  //   try {
  //     if (supabase.auth.currentSession != null) {
  //       await supabase.auth.refreshSession();
  //       _logger.info('Session refreshed successfully');
  //     } else {
  //       _logger.info('No session to refresh');
  //     }
  //   } catch (e) {
  //     _logger.severe('Error refreshing session: $e');
  //   }
  // }
  
  // // Get the current user ID or throw an exception if not authenticated
  // String getCurrentUserId() {
  //   final userId = supabase.auth.currentUser?.id;
  //   if (userId == null) {
  //     throw Exception('User not authenticated');
  //   }
  //   return userId;
  // }
}
  
    
