import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../config/api_keys.dart';
import 'cached_tile_provider.dart';

/// Centralized map-tile config. Uses Stadia Maps for the base tiles
/// and falls back to raw OSM Carto if no API key is provided at build
/// time.
///
/// Stadia free tier: 200K tile requests/month. Tiles are cached on disk
/// via flutter_cache_manager, so a runner who repeats their loop pays
/// the network cost once.
///
/// Style notes:
///   - "outdoors"             dense, colorful, terrain + hiking paths —
///                            Stadia's recommended style for fitness /
///                            running apps. This is the current default
///                            because the smoother dark styles read as
///                            generic next to Strava's tile detail.
///   - "alidade_smooth_dark"  minimalist dark; readable but sparse.
///   - "osm_bright"           densest OSM-style; lots of labels.
///   - "alidade_satellite"    satellite imagery.
class MapTiles {
  /// Stadia style key. Bump this to switch the entire app's tiles.
  static const String _stadiaStyle = 'outdoors';

  static TileLayer baseLayer() {
    if (ApiKeys.hasStadia) {
      return TileLayer(
        urlTemplate:
            'https://tiles.stadiamaps.com/tiles/$_stadiaStyle/{z}/{x}/{y}@2x.png?api_key=${ApiKeys.stadiaMaps}',
        userAgentPackageName: 'com.jvcerezo.daloy',
        tileProvider: CachedTileProvider(),
        maxNativeZoom: 20,
        retinaMode: false, // we already request @2x in the URL
      );
    }
    // Fallback so dev builds without the key still show something.
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
