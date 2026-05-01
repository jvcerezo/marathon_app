import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/tokens.dart';
import '../models/completed_run.dart';
import 'run_share_card.dart';
import 'stories_share_channel.dart';

/// Full-screen share preview. The card is a transparent PNG overlay
/// designed to be dropped over a user-supplied photo or video in
/// Stories. Two share actions:
///
///   1. **Share to Stories** — uses Instagram's sticker intent so the
///      overlay arrives draggable + resizable on top of the user's
///      chosen background. This is the Strava behavior.
///   2. **Other apps** — system share sheet for everything else
///      (Twitter, save to Files, etc).
class ShareRunScreen extends StatefulWidget {
  final CompletedRun run;
  const ShareRunScreen({super.key, required this.run});

  @override
  State<ShareRunScreen> createState() => _ShareRunScreenState();
}

class _ShareRunScreenState extends State<ShareRunScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _busy = false;
  bool _instagramAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkInstagram();
  }

  Future<void> _checkInstagram() async {
    final available = await StoriesShareChannel.isInstagramInstalled();
    if (mounted) {
      setState(() => _instagramAvailable = available);
    }
  }

  Future<void> _shareToStories() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _captureToFile();
      await StoriesShareChannel.shareToInstagramStories(file.path);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final message = e.code == 'ig-not-installed'
          ? 'Instagram isn\'t installed on this device.'
          : 'Could not open Instagram Stories: ${e.message ?? 'unknown error'}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not prepare share image: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareViaSystemSheet() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _captureToFile();
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Find your daloy.',
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not prepare share image: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _captureToFile() async {
    final boundary = _cardKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    // 3x DPR → 1080x1920 PNG with alpha, ready for IG Stories.
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode share card to PNG.');
    }
    final bytes = byteData.buffer.asUint8List();
    // Cache dir is what FileProvider exposes via the cache-path entry in
    // res/xml/file_paths.xml — Instagram needs a content:// URI it can
    // read across the app boundary.
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/daloy-run-${widget.run.id}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.bone),
          title: const Text(
            'Share',
            style:
                TextStyle(color: AppColors.bone, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.bone),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
            const SizedBox(width: 4),
          ],
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md,
                ),
                child: Text(
                  'Share to Stories drops the overlay on as a draggable '
                  'sticker, with your photo or video as the background.',
                  style: TextStyle(
                    color: AppColors.fog,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxH = constraints.maxHeight;
                        final maxW = constraints.maxWidth;
                        final byHeight = maxH * 9 / 16;
                        final cardWidth = byHeight < maxW ? byHeight : maxW;
                        final cardHeight = cardWidth * 16 / 9;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: Stack(
                              children: [
                                // Placeholder backdrop: communicates "your
                                // photo or video goes here." NOT included
                                // in the capture — the RepaintBoundary
                                // wraps only the overlay.
                                const Positioned.fill(child: _PreviewBackdrop()),
                                // Capture target: transparent overlay only.
                                RepaintBoundary(
                                  key: _cardKey,
                                  child: RunShareCard(
                                    run: widget.run,
                                    width: cardWidth,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    if (_instagramAvailable)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _shareToStories,
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.ink,
                                  ),
                                )
                              : const Icon(PhosphorIconsRegular.instagramLogo),
                          label: Text(
                            _busy ? 'Preparing…' : 'Share to Stories',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.pulse,
                            foregroundColor: AppColors.ink,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ),
                    if (_instagramAvailable) const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _shareViaSystemSheet,
                        icon: const Icon(
                          PhosphorIconsRegular.shareFat,
                          color: AppColors.bone,
                        ),
                        label: Text(
                          _instagramAvailable ? 'Other apps' : 'Share',
                          style: const TextStyle(
                            color: AppColors.bone,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.iron),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder shown behind the transparent overlay in the preview pane,
/// to communicate "your photo or video will go here." Pure visual aid —
/// not captured into the shared PNG.
class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A3340),
            Color(0xFF161B25),
            Color(0xFF0E1218),
          ],
        ),
      ),
    );
  }
}
