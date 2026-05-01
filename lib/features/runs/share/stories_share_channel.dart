import 'package:flutter/services.dart';

/// Thin wrapper around the Android-side `daloy/share` method channel.
///
/// Sends a transparent PNG to Instagram Stories as a draggable
/// `interactive_asset_uri` sticker, matching the behavior of Strava's
/// "Share to Stories" flow. The user picks the background photo or
/// video inside Stories; our overlay arrives pre-attached as a sticker
/// that can be moved, resized, or rotated.
class StoriesShareChannel {
  static const _channel = MethodChannel('daloy/share');

  /// Returns `true` if Instagram is installed and reachable. Used to
  /// hide the "Share to Stories" button on devices without IG.
  static Future<bool> isInstagramInstalled() async {
    try {
      return await _channel.invokeMethod<bool>('isInstagramInstalled') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Launches Instagram Stories with [pngPath] as the sticker. Throws
  /// a [PlatformException] with code `ig-not-installed` if Instagram
  /// isn't on the device, or `share-failed` for any other error.
  static Future<void> shareToInstagramStories(String pngPath) async {
    await _channel.invokeMethod<void>(
      'shareToInstagramStories',
      <String, Object?>{'path': pngPath},
    );
  }
}
