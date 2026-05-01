import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../config/api_keys.dart';
import 'cached_tile_provider.dart';

/// Centralized map-tile config. We use Stadia Maps for Strava-grade
/// rendering (detailed streets, building footprints, dark mode aesthetic)
/// and fall back to raw OSM Carto if the build wasn't given an API key.
///
/// Stadia free tier: 200K tile requests/month. Tiles are cached on disk
/// via flutter_cache_manager, so a runner who repeats their loop pays the
/// network cost once.
class MapTiles {
  /// Primary base layer. `alidade_smooth_dark` is a clean dark style with
  /// fine-grained street + building rendering — close to Strava's dark
  /// map mode.
  static TileLayer baseLayer() {
    if (ApiKeys.hasStadia) {
      return TileLayer(
        urlTemplate:
            'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}@2x.png?api_key=${ApiKeys.stadiaMaps}',
        userAgentPackageName: 'com.jvcerezo.daloy',
        tileProvider: CachedTileProvider(),
        maxNativeZoom: 20,
        retinaMode: false, // we already request @2x in the URL
      );
    }
    // Fallback so the app degrades gracefully (and dev builds without the
    // key still show something).
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.jvcerezo.daloy',
      tileProvider: CachedTileProvider(),
      maxNativeZoom: 19,
    );
  }

  /// Required attribution overlay. Stadia + OpenMapTiles + OSM all need
  /// to be credited per their TOS. Sized for the bottom-left corner.
  static Widget attribution() {
    final text = ApiKeys.hasStadia
        ? '© Stadia Maps © OpenMapTiles © OpenStreetMap'
        : '© OpenStreetMap contributors';
    return Positioned(
      left: 6,
      bottom: 6,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xAA000000),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 9,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
