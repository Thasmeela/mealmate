import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dw93u4s6s', // TODO: Replace with your Cloudinary Cloud Name
    'ez-meal', // TODO: Replace with your Cloudinary Upload Preset
    cache: false,
  );

  Future<String?> uploadImage(dynamic imageFile) async {
    try {
      CloudinaryResponse response;
      if (kIsWeb) {
        // On web, imageFile is likely a byte array or a path that needs conversion
        // imageFile here should ideally be the bytes for web
        if (imageFile is Uint8List) {
          response = await _cloudinary.uploadFile(
            CloudinaryFile.fromBytesData(
              imageFile,
              identifier:
                  'recipe_image_${DateTime.now().millisecondsSinceEpoch}',
              folder: 'mealmate/recipes',
            ),
          );
        } else {
          throw Exception("For web, please provide image bytes.");
        }
      } else {
        // On mobile
        if (imageFile is File) {
          response = await _cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              imageFile.path,
              folder: 'mealmate/recipes',
            ),
          );
        } else {
          throw Exception("For mobile, please provide a File object.");
        }
      }
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
