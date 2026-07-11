import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/ui/widgets/contained_image_frame.dart';
import 'package:reforge/features/camera_detection/ui/widgets/pose_detection_image.dart';
import 'package:reforge/features/camera_detection/ui/widgets/upload_image_widget.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';
import 'package:reforge/shared/uikit/buttons/text_button.dart';

class CameraDetectionImageSection extends StatelessWidget {
  const CameraDetectionImageSection({
    required this.state,
    required this.onPickImage,
    required this.onPoseInteractionStart,
    required this.onPoseInteractionEnd,
    super.key,
  });

  final CameraDetectionState state;
  final VoidCallback onPickImage;
  final VoidCallback onPoseInteractionStart;
  final VoidCallback onPoseInteractionEnd;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(t.camera_detection.yourImage, style: subheadH3Medium.copyWith(color: context.appTheme.beige100)),
              if (state is CameraDetectionAdjusting && (state as CameraDetectionAdjusting).hasManualChange)
                AppTextButton(
                  onPressed: context.read<CameraDetectionCubit>().resetPoints,
                  text: t.camera_detection.resetPoints,
                  assetPath: Assets.images.icons.close,
                ),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 316 / 415,
          child: CustomPaint(
            painter: DashedBorderPainter(color: appTheme.strokeCard, strokeWidth: 1, radius: 20),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _ImageContent(
                state: state,
                onPickImage: onPickImage,
                onPoseInteractionStart: onPoseInteractionStart,
                onPoseInteractionEnd: onPoseInteractionEnd,
              ),
            ),
          ),
        ),
        if (state.hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextButton(
                  onPressed: onPickImage,
                  text: t.camera_detection.replaceImage,
                  assetPath: Assets.images.icons.reload,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({
    required this.state,
    required this.onPickImage,
    required this.onPoseInteractionStart,
    required this.onPoseInteractionEnd,
  });

  final CameraDetectionState state;
  final VoidCallback onPickImage;
  final VoidCallback onPoseInteractionStart;
  final VoidCallback onPoseInteractionEnd;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CameraDetectionInitial() => UploadImageWidget(onPressed: onPickImage),
      CameraDetectionImageSelected(:final imagePath, :final originalImageSize) => _SelectedImage(
        imagePath: imagePath,
        originalImageSize: originalImageSize,
      ),
      CameraDetectionAnalyzing(:final imagePath, :final originalImageSize) => _SelectedImage(
        imagePath: imagePath,
        originalImageSize: originalImageSize,
        isLoading: true,
      ),
      CameraDetectionAdjusting(
        :final imagePath,
        :final originalImageSize,
        :final points,
        :final angleResult,
      ) =>
        PoseDetectionImage(
          imagePath: imagePath,
          originalImageSize: originalImageSize,
          points: points,
          angleResult: angleResult,
          onPointMoved: (pointNumber, position) {
            context.read<CameraDetectionCubit>().movePoint(
              pointNumber: pointNumber,
              position: position,
            );
          },
          onInteractionStart: onPoseInteractionStart,
          onInteractionEnd: onPoseInteractionEnd,
        ),
      CameraDetectionSavingResult(
        :final imagePath,
        :final originalImageSize,
        :final points,
        :final angleResult,
      ) =>
        PoseDetectionImage(
          imagePath: imagePath,
          originalImageSize: originalImageSize,
          points: points,
          angleResult: angleResult,
          onPointMoved: (_, _) {},
          onInteractionStart: onPoseInteractionStart,
          onInteractionEnd: onPoseInteractionEnd,
        ),
    };
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    required this.imagePath,
    required this.originalImageSize,
    this.isLoading = false,
  });

  final String imagePath;
  final Size originalImageSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ContainedImageFrame(
      imagePath: imagePath,
      originalImageSize: originalImageSize,
      builder: (context, transform) {
        if (!isLoading) return const SizedBox.shrink();

        return Positioned.fromRect(
          rect: transform.imageRect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.appTheme.beige1000.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
