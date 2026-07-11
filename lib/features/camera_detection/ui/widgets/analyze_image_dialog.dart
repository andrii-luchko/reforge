import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/ui/painters/analyze_scan_painter.dart';
import 'package:reforge/features/camera_detection/ui/widgets/contained_image_frame.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class AnalyzeImageDialog extends StatelessWidget {
  const AnalyzeImageDialog({
    required this.imagePath,
    required this.originalImageSize,
    required this.onClosePressed,
    super.key,
  });

  final String imagePath;
  final Size originalImageSize;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CameraDetectionCubit, CameraDetectionState, double>(
      selector: (state) {
        return switch (state) {
          CameraDetectionAnalyzing(:final displayProgress) => displayProgress,
          _ => 0,
        };
      },
      builder: (context, progress) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultDialogHeader(
                title: t.camera_detection.analyzeImage,
                onClosePressed: onClosePressed,
              ),
              const SizedBox(height: 32),
              AspectRatio(
                aspectRatio: 316 / 415,
                child: GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ContainedImageFrame(
                        imagePath: imagePath,
                        originalImageSize: originalImageSize,
                        borderRadius: BorderRadius.circular(16),
                        builder: (context, transform) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fromRect(
                                rect: transform.imageRect,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: context.appTheme.beige1000.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fromRect(
                                rect: transform.imageRect,
                                child: CustomPaint(
                                  painter: AnalyzeScanPainter(
                                    progress: progress,
                                    theme: context.appTheme,
                                    textDirection: Directionality.of(context),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                t.camera_detection.analyzingTitle,
                textAlign: TextAlign.center,
                style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
              ),
              const SizedBox(height: 12),
              Text(
                t.camera_detection.analyzingDescription,
                textAlign: TextAlign.center,
                style: bodyLRegular.copyWith(color: context.appTheme.beige600),
              ),
            ],
          ),
        );
      },
    );
  }
}
