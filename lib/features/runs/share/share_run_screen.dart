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

/// Full-screen share preview. The card itself is a transparent overlay
/// designed to be dropped over a user-supplied photo or video in
/// Stories. The preview background is a placeholder gradient that
/// communicates "your photo will go here" — it isn't part of the
/// captured PNG (the RepaintBoundary wraps only the card).
class ShareRunScreen extends StatefulWidget {
  final CompletedRun run;
  const ShareRunScreen({super.key, required this.run});

  @override
  State<ShareRunScreen> createState() => _ShareRunScreenState();
}

class _ShareRunScreenState extends State<ShareRunScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not prepare share image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _captureToFile() async {
    final boundary = _cardKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    // Capture at 3x DPR so a 360x640 logical card becomes a 1080x1920 PNG.
    // The card itself has a transparent background, so the resulting PNG
    // is alpha-transparent and ready to overlay on any photo.
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode share card to PNG.');
    }
    final bytes = byteData.buffer.asUint8List();
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
            style: TextStyle(color: AppColors.bone, fontWeight: FontWeight.w600),
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
                  'Drop this overlay onto your photo or video in Instagram Stories.',
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
                                Positioned.fill(
                                  child: const _PreviewBackdrop(),
                                ),
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
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _share,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : const Icon(PhosphorIconsRegular.shareFat),
                    label: Text(
                      _busy ? 'Preparing…' : 'Share',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pulse,
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
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
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
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
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'YOUR PHOTO',
              style: TextStyle(
                color: const Color(0xFF1F2630).withValues(alpha: 0.0),
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
