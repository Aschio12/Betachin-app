import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Proper conditional imports
import 'dart:io' show File;
// Import only what we need from dart:html when on web
import 'package:universal_html/html.dart' as html
    if (dart.library.io) 'no_web.dart';

class StorageService {
  final SupabaseClient supabase;
  final _logger = Logger('StorageService');

  StorageService({required this.supabase});

  // Upload a file from mobile
  Future<String> uploadFile(File file, String filePath) async {
    try {
      final fileExt = file.path.split('.').last;
      final filePathWithExt = '$filePath.$fileExt';
      _logger.info('Mobile upload: bucket=images, path=$filePathWithExt');

      await supabase.storage.from('images').upload(
            filePathWithExt,
            file,
          );

      final imageUrl =
          supabase.storage.from('images').getPublicUrl(filePathWithExt);
      _logger.info('Mobile image URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      _logger.severe('Error uploading file: $e');
      rethrow;
    }
  }

  // Upload a file from web
  Future<String> uploadWebFile(html.File file, String filePath) async {
    try {
      final bytes = await _readWebFileAsBytes(file);
      _logger.info(
          'Web upload: bucket=images, path=$filePath, contentType=${file.type}');

      await supabase.storage.from('images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: file.type),
          );

      final imageUrl = supabase.storage.from('images').getPublicUrl(filePath);
      _logger.info('Web image URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      _logger.severe('Error uploading web file: $e');
      rethrow;
    }
  }

  // Helper method to read web file as bytes
  Future<Uint8List> _readWebFileAsBytes(html.File file) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onLoadEnd.listen((event) {
      final result = reader.result as Uint8List;
      completer.complete(result);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }
}
