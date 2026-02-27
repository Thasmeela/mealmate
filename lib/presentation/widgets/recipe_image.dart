import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class RecipeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[900],
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }

    // Local file path (mobile only)
    if (!kIsWeb && imageUrl.isNotEmpty) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      }
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.restaurant, color: Colors.white54, size: 40),
      ),
    );
  }
}
