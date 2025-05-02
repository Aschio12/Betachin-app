import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';

class FavoritesService {
  final SupabaseClient supabase;
  final _logger = Logger('FavoritesService');

  FavoritesService({required this.supabase});

  // Toggle favorite
  Future<void> toggleFavorite(int propertyId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if already favorited
      final existingFav = await supabase
          .from('favorites')
          .select()
          .eq('property_id', propertyId)
          .eq('user_id', userId);

      if ((existingFav as List).isEmpty) {
        // Add to favorites
        await supabase.from('favorites').insert({
          'property_id': propertyId,
          'user_id': userId,
        });
      } else {
        // Remove from favorites
        await supabase
            .from('favorites')
            .delete()
            .eq('property_id', propertyId)
            .eq('user_id', userId);
      }
    } catch (e) {
      _logger.severe('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Get user favorites
  Future<List<int>> getUserFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await supabase
          .from('favorites')
          .select('property_id')
          .eq('user_id', userId);

      final List<dynamic> data = response;
      return data.map<int>((item) => item['property_id'] as int).toList();
    } catch (e) {
      _logger.severe('Error getting user favorites: $e');
      rethrow;
    }
  }

  // Get favorite properties
  Future<List<PropertyModel>> getFavoriteProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get favorite IDs first
      final favoriteIds = await getUserFavorites();

      // If no favorites, return empty list early
      if (favoriteIds.isEmpty) {
        return [];
      }

      // Get all properties that match the favorite IDs
      var query = supabase.from('properties').select('''
        *,
        property_images(image_url, is_primary)
      ''').inFilter('id', favoriteIds);

      final response = await query;
      final List<dynamic> data = response;

      // Process the data
      Map<int, Map<String, dynamic>> propertyMap = {};
      Map<int, List<Map<String, dynamic>>> propertyImages = {};

      for (var item in data) {
        final propertyId = item['id'] as int;

        // If we haven't seen this property before, create the base property data
        if (!propertyMap.containsKey(propertyId)) {
          propertyMap[propertyId] = {
            'id': propertyId,
            'user_id': item['user_id'],
            'property_name': item['property_name'],
            'address': item['address'],
            'floor': item['floor'],
            'city': item['city'],
            'bath_rooms': item['bath_rooms'],
            'bed_rooms': item['bed_rooms'],
            'square_feet': item['square_feet'],
            'price': item['price'],
            'description': item['description'],
            'type': item['type'],
            'listing_type': item['listing_type'],
            'rating': item['rating'] ?? 0.0,
            'created_at': item['created_at'],
            'is_active': item['is_active'] ?? true,
          };
          propertyImages[propertyId] = [];
        }

        // Process property images
        if (item['property_images'] != null) {
          final images = item['property_images'] as List;
          for (var image in images) {
            if (image != null && image['image_url'] != null) {
              propertyImages[propertyId]!.add({
                'image_url': image['image_url'],
                'is_primary': image['is_primary'] ?? false,
              });
            }
          }
        }
      }

      // Convert to PropertyModel objects
      List<PropertyModel> properties = [];
      for (var propertyId in propertyMap.keys) {
        final Map<String, dynamic> property = propertyMap[propertyId]!;
        final imageData = propertyImages[propertyId] ?? [];
        property['image_urls'] =
            imageData.map((img) => img['image_url'] as String).toList();
        property['primary_image_url'] = imageData.firstWhere(
          (img) => img['is_primary'] == true,
          orElse: () =>
              imageData.isNotEmpty ? imageData[0] : {'image_url': null},
        )['image_url'];

        properties.add(PropertyModel.fromJson(property));
      }

      return properties;
    } catch (e) {
      _logger.severe('Error fetching favorite properties: $e');
      rethrow;
    }
  }
}
