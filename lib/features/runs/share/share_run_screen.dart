import 'dart:io';
import 'dart:typed_data';
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

/// Full-screen share preview. Renders the [RunShareCard] at design size,
/// captures it at high pixel ratio, writes a PNG to the temp dir, and
/// hands it off to the system share sheet.
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
    // Capture at 3x DPR so a 360x640 logical card becomes a 1080x1920 PNG —
    // crisp on Stories, IG feed, and most share targets.
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
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Fit the 9:16 card within the available area while
                        // leaving room for the share button below.
                        final maxH = constraints.maxHeight;
                        final maxW = constraints.maxWidth;
                        final byHeight = maxH * 9 / 16;
                        final cardWidth = byHeight < maxW ? byHeight : maxW;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          child: RepaintBoundary(
                            key: _cardKey,
                            child: RunShareCard(
                              run: widget.run,
                              width: cardWidth,
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
