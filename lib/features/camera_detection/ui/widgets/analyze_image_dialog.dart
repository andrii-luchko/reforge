import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/ui/widgets/contained_image_frame.dart';
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
                title: 'Analyze image',
                onClosePressed: onClosePressed,
              ),
              const SizedBox(height: 32),
              AspectRatio(
                aspectRatio: 316 / 415,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ContainedImageFrame(
                      imagePath: imagePath,
                      originalImageSize: originalImageSize,
                      borderRadius: BorderRadius.circular(16),
                      builder: (context, transform) {
                        return Stack(
                          clipBehavior: .none,
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
                            if (progress != 0)
                              Positioned.fromRect(
                                rect: transform.imageRect,
                                child: CustomPaint(
                                  painter: _AnalyzeScanPainter(
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
              const SizedBox(height: 32),
              Text(
                'Analyzing Your Posture...',
                textAlign: TextAlign.center,
                style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
              ),
              const SizedBox(height: 12),
              Text(
                "We're detecting key body positions\nand movement patterns",
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

abstract final class _AnalyzeScanMetrics {
  static const designSize = Size(357, 432);

  static double scanY(Size size, double progress) {
    final scaleY = size.height / designSize.height;
    final frameHeight = 360 * scaleY;
    final frameTop = (size.height - frameHeight) / 2;

    return frameTop + (size.height - frameTop) * progress.clamp(0, 1);
  }
}

class _AnalyzeScanPainter extends CustomPainter {
  const _AnalyzeScanPainter({
    required this.progress,
    required this.theme,
    required this.textDirection,
  });

  final double progress;
  final AppTheme theme;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _AnalyzeScanMetrics.designSize.width;
    final scaleY = size.height / _AnalyzeScanMetrics.designSize.height;

    final frameWidth = 260 * scaleX;
    final frameHeight = 360 * scaleY;
    final frameRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: frameWidth,
      height: frameHeight,
    );
    final topLineY = 53 * scaleY;
    final bottomLineY = 378 * scaleY;
    final squareSide = 8 * ((scaleX + scaleY) / 2);

    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(size.width / 2, topLineY),
        width: frameWidth * 1.15,
        height: 1 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.beige100.withValues(alpha: 0.2),
        theme.beige100.withValues(alpha: 0.72),
        theme.beige100.withValues(alpha: 0.2),
      ],
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(size.width / 2, bottomLineY),
        width: frameWidth * 1.15,
        height: 1 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.beige100.withValues(alpha: 0.1),
        theme.beige100.withValues(alpha: 0.72),
        theme.beige100.withValues(alpha: 0.2),
      ],
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(frameRect.left, size.height / 2),
        width: 1 * scaleX,
        height: frameHeight,
      ),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.beige100.withValues(alpha: 0.2),
        theme.beige100.withValues(alpha: 0.72),
        theme.beige100.withValues(alpha: 0.2),
      ],
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(frameRect.right, size.height / 2),
        width: 1 * scaleX,
        height: frameHeight,
      ),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.beige100.withValues(alpha: 0.2),
        theme.beige100.withValues(alpha: 0.72),
        theme.beige100.withValues(alpha: 0.2),
      ],
    );

    final squarePaint = Paint()..color = theme.beige100;
    for (final center in [
      Offset(frameRect.left, topLineY),
      Offset(frameRect.right, topLineY),
      Offset(frameRect.left, bottomLineY),
      Offset(frameRect.right, bottomLineY),
    ]) {
      canvas.drawRect(Rect.fromCenter(center: center, width: squareSide, height: squareSide), squarePaint);
    }

    final scanY = _AnalyzeScanMetrics.scanY(size, progress);
    final scanWidth = 283.78 * scaleX;
    final scanCenterX = size.width / 2;
    final averageScale = (scaleX + scaleY) / 2;

    _drawScanAtmosphere(
      canvas,
      size: size,
      scanY: scanY,
      scanCenterX: scanCenterX,
      scaleX: scaleX,
      scaleY: scaleY,
      averageScale: averageScale,
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(scanCenterX, scanY),
        width: scanWidth,
        height: 6.27 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.orange500.withValues(alpha: 0),
        theme.orange500,
        theme.orange500.withValues(alpha: 0),
      ],
      blurSigma: 2 * averageScale,
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(scanCenterX, scanY),
        width: scanWidth,
        height: 4.48 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.beige100.withValues(alpha: 0),
        theme.beige100.withValues(alpha: 0.86),
        theme.beige100.withValues(alpha: 0),
      ],
      blurSigma: 2 * averageScale,
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(scanCenterX, scanY),
        width: scanWidth,
        height: 0.9 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.beige100.withValues(alpha: 0),
        theme.beige100,
        theme.beige100.withValues(alpha: 0),
      ],
      blurSigma: 0.5 * averageScale,
    );
    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(scanCenterX, scanY),
        width: 179.04 * scaleX,
        height: 0.9 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.beige100.withValues(alpha: 0),
        theme.beige100,
        theme.beige100.withValues(alpha: 0),
      ],
    );

    _drawProgressText(
      canvas,
      size: size,
      scanY: scanY,
      scaleY: scaleY,
    );
  }

  void _drawScanAtmosphere(
    Canvas canvas, {
    required Size size,
    required double scanY,
    required double scanCenterX,
    required double scaleX,
    required double scaleY,
    required double averageScale,
  }) {
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, 0, size.width, scanY));

    final cloudRect = Rect.fromCenter(
      center: Offset(scanCenterX, scanY),
      width: 220 * scaleX,
      height: 140 * scaleY,
    );
    final cloudPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.orange500.withValues(alpha: 1),
          theme.orange500.withValues(alpha: 1),
          theme.orange500.withValues(alpha: 0.5),
        ],
        stops: const [0, 0.42, 1],
      ).createShader(cloudRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 * averageScale)
      ..blendMode = BlendMode.screen;

    canvas.drawOval(cloudRect, cloudPaint);

    final gasPaint = Paint()
      ..color = theme.orange500.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 46 * averageScale)
      ..blendMode = BlendMode.screen;

    canvas
      ..drawCircle(Offset(scanCenterX, scanY - 44 * scaleY), 52 * averageScale, gasPaint)
      ..drawCircle(Offset(scanCenterX - 46 * scaleX, scanY - 62 * scaleY), 42 * averageScale, gasPaint)
      ..drawCircle(Offset(scanCenterX + 54 * scaleX, scanY - 70 * scaleY), 46 * averageScale, gasPaint);

    _drawGradientRect(
      canvas,
      Rect.fromCenter(
        center: Offset(scanCenterX, scanY - 4 * scaleY),
        width: size.width * 1.12,
        height: 38 * scaleY,
      ),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        theme.orange500.withValues(alpha: 0),
        theme.orange500.withValues(alpha: 0.24),
        theme.orange500.withValues(alpha: 0),
      ],
      blurSigma: 14 * averageScale,
    );

    // _drawDust(canvas, size: size, scanY: scanY, scaleX: scaleX, scaleY: scaleY);
    canvas.restore();
  }

  // void _drawDust(
  //   Canvas canvas, {
  //   required Size size,
  //   required double scanY,
  //   required double scaleX,
  //   required double scaleY,
  // }) {
  //   final paint = Paint()..color = theme.orange200.withValues(alpha: 0.45);
  //   const particles = [
  //     Offset(0.58, -42),
  //     Offset(0.62, -54),
  //     Offset(0.66, -34),
  //     Offset(0.71, -47),
  //     Offset(0.75, -58),
  //     Offset(0.79, -38),
  //     Offset(0.83, -51),
  //     Offset(0.87, -44),
  //     Offset(0.91, -60),
  //     Offset(0.94, -36),
  //   ];

  //   for (var i = 0; i < particles.length; i++) {
  //     final particle = particles[i];
  //     final radius = (i.isEven ? 0.8 : 1.2) * scaleX;
  //     canvas.drawCircle(
  //       Offset(size.width * particle.dx, scanY + particle.dy * scaleY),
  //       radius,
  //       paint,
  //     );
  //   }
  // }

  void _drawProgressText(
    Canvas canvas, {
    required Size size,
    required double scanY,
    required double scaleY,
  }) {
    final percent = (progress * 100).clamp(0, 100).round();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percent%',
        style: subheadH1Medium.copyWith(color: theme.beige100),
      ),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    )..layout(maxWidth: size.width);
    final textGap = 10 + scaleY;
    final textTop = (scanY - textGap - textPainter.height).clamp(0.0, size.height - textPainter.height);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        textTop,
      ),
    );
  }

  void _drawGradientRect(
    Canvas canvas,
    Rect rect, {
    required Alignment begin,
    required Alignment end,
    required List<Color> colors,
    double? blurSigma,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        stops: const [0, 0.5, 1],
        begin: begin,
        end: end,
      ).createShader(rect);

    if (blurSigma != null) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    }

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _AnalyzeScanPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.theme != theme || oldDelegate.textDirection != textDirection;
  }
}
