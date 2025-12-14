import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sports_config_app/core/network/media_headers.dart';

class AppImageCacheManager extends CacheManager {
  static const key = 'appImageCache';

  static final AppImageCacheManager instance = AppImageCacheManager._();

  AppImageCacheManager._()
      : super(
    Config(
      key,
      stalePeriod: const Duration(days: 3), // cât păstrează
      maxNrOfCacheObjects: 250,            // limită “light”
    ),
  );
}

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u == null || u.isEmpty) {
      return _placeholder();
    }

    final img = CachedNetworkImage(
      httpHeaders: mediaHeaders,
      imageUrl: u,
      cacheManager: AppImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );

    if (borderRadius == null) return img;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: img,
    );
  }

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: Colors.white10,
    alignment: Alignment.center,
    child: const Icon(Icons.image, size: 18, color: Colors.white38),
  );
}