import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design/tokens.dart';
import '../models/completed_run.dart';
import 'run_share_card.dart';

/// In-app share composer. Pick or capture a photo, then position,
/// scale, and rotate the run overlay on top with native pinch gestures.
/// Save the composed image to the device gallery — from there the user
/// uploads it anywhere they want, no third-party share intent involved.
///
/// Drives a 9:16 canvas matching Instagram Stories / TikTok / YouTube
/// Shorts so the saved image lands at the right aspect for vertical
/// social formats.
class ComposeRunScreen extends StatefulWidget {
  final CompletedRun run;
  const ComposeRunScreen({super.key, required this.run});

  @override
  State<ComposeRunScreen> createState() => _ComposeRunScreenState();
}

class _ComposeRunScreenState extends State<ComposeRunScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _composerKey = GlobalKey();

  XFile? _photo;
  bool _saving = false;

  // Currently-selected overlay tint. Threads into RunShareCard.color
  // and recolors every visible element (stat text, polyline, logo,
  // wordmark) in one shot.
  Color _overlayColor = Colors.white;

  // Overlay transform — accumulated across gestures.
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  // Snapshots taken at gesture start so onScaleUpdate's deltas can be
  // applied to the pre-gesture state instead of compounding per frame.
  Offset _baseOffset = Offset.zero;
  double _baseScale = 1.0;
  double _baseRotation = 0.0;
  Offset _baseFocal = Offset.zero;

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        // Cap input at slightly above our 1080x1920 capture target so we
        // don't load 50 MP camera-roll photos into memory.
        maxWidth: 2160,
        maxHeight: 3840,
      );
      if (picked != null && mounted) {
        setState(() => _photo = picked);
      }
    } catch (e) {
      _showError('Could not open gallery: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2160,
        maxHeight: 3840,
      );
      if (picked != null && mounted) {
        setState(() => _photo = picked);
      }
    } catch (e) {
      _showError('Could not open camera: $e');
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseOffset = _offset;
    _baseScale = _scale;
    _baseRotation = _rotation;
    _baseFocal = d.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _scale = (_baseScale * d.scale).clamp(0.3, 4.0);
      _rotation = _baseRotation + d.rotation;
      _offset = _baseOffset + (d.focalPoint - _baseFocal);
    });
  }

  void _resetTransform() {
    setState(() {
      _offset = Offset.zero;
      _scale = 1.0;
      _rotation = 0.0;
    });
  }

  Future<void> _save() async {
    if (_saving || _photo == null) return;
    setState(() => _saving = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showError(
            'Storage permission denied. Enable photos access in system settings.',
          );
          return;
        }
      }

      final boundary = _composerKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      // Capture at 3x DPR so a 360x640 canvas renders to 1080x1920.
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to encode composed image to PNG.');
      }
      final bytes = byteData.buffer.asUint8List();

      // Persist via a temp file so Gal has a real path to ingest.
      final dir = Directory.systemTemp;
      final file = File(
        '${dir.path}/daloy-compose-${widget.run.id}-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await Gal.putImage(file.path, album: 'Daloy');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to your photos.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on GalException catch (e) {
      _showError('Could not save: ${e.type.message}');
    } catch (e) {
      _showError('Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            if (_photo != null)
              IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
                tooltip: 'Reset position',
                color: AppColors.bone,
                onPressed: _resetTransform,
              ),
            IconButton(
              icon: const Icon(Icons.close),
              color: AppColors.bone,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
            const SizedBox(width: 4),
          ],
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: _photo == null ? _buildEmptyState() : _buildComposer(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          const Icon(
            PhosphorIconsDuotone.image,
            size: 64,
            color: AppColors.fog,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Add a photo',
            style: TextStyle(
              color: AppColors.bone,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Pick a photo or take one. The run overlay drops on top — '
              'drag, pinch, and rotate it wherever you want.',
              style: TextStyle(
                color: AppColors.fog,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(PhosphorIconsRegular.image),
              label: const Text(
                'Pick from gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(PhosphorIconsRegular.camera),
              label: const Text(
                'Take a photo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bone,
                side: const BorderSide(color: AppColors.iron),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md,
          ),
          child: Text(
            'Drag with one finger. Pinch with two to scale and rotate.',
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
                  final canvasW = byHeight < maxW ? byHeight : maxW;
                  final canvasH = canvasW * 16 / 9;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    child: SizedBox(
                      width: canvasW,
                      height: canvasH,
                      // GestureDetector outside the RepaintBoundary so
                      // gesture state changes don't trigger re-paint of
                      // a heavier subtree, but the same layout area
                      // captures both the photo and the overlay.
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        child: RepaintBoundary(
                          key: _composerKey,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background photo, fitted to fill the
                              // canvas (cropped if needed — same as
                              // Stories' default photo behavior).
                              Image.file(
                                File(_photo!.path),
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                              // Transformable overlay.
                              Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..translate(_offset.dx, _offset.dy)
                                    ..rotateZ(_rotation)
                                    ..scale(_scale),
                                  child: RunShareCard(
                                    run: widget.run,
                                    width: canvasW,
                                    color: _overlayColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: _ColorPicker(
            current: _overlayColor,
            onChanged: (c) => setState(() => _overlayColor = c),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : const Icon(PhosphorIconsRegular.downloadSimple),
                  label: Text(
                    _saving ? 'Saving…' : 'Save to photos',
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
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _pickFromGallery,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mist,
                ),
                child: const Text(
                  'Change photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal row of color swatches for tinting the overlay (stat
/// text, polyline, logo, wordmark — everything that's drawn on top
/// of the photo). Five hand-picked options cover the common cases:
/// white reads on dark photos, black reads on bright photos, the
/// brand greens and ember are for stylized looks.
class _ColorPicker extends StatelessWidget {
  static const List<Color> _swatches = [
    Colors.white,
    Color(0xFF0A0E14), // ink — pairs with bright photos
    AppColors.pulse,
    AppColors.ember,
    Color(0xFFFFC857), // warm yellow
    Color(0xFFFF4D6D), // hot pink
    Color(0xFF4D9CFF), // cool blue
  ];

  final Color current;
  final ValueChanged<Color> onChanged;

  const _ColorPicker({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in _swatches) ...[
            _Swatch(
              color: c,
              selected: c == current,
              onTap: () => onChanged(c),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = selected ? AppColors.bone : AppColors.iron;
    final ringWidth = selected ? 3.0 : 1.5;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: ringWidth),
        ),
      ),
    );
  }
}
