import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// flutter_map TileProvider that delegates to flutter_cache_manager via
/// cached_network_image. Tiles persist on disk between launches and
/// auto-evict on the cache manager's default schedule (~30-day TTL,
/// ~200MB cap), so a runner who repeats their loop pays the network
/// cost once.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({super.headers});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      headers: headers,
    );
  }
}
