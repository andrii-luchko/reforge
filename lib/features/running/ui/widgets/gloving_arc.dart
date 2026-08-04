import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ignore: prefer_match_file_name
class GlowingArc extends StatefulWidget {
  const GlowingArc({
    required this.animation,
    this.height = 250,
    super.key,
  });

  final double height;
  final Animation<double> animation;

  @override
  State<GlowingArc> createState() => _GlowingArcState();
}

class _GlowingArcState extends State<GlowingArc> {
  Float32List? _noisePoints;
  Size? _lastSize;

  void _generateNoise(Size size) {
    if (_noisePoints != null && _lastSize == size) return;
    _lastSize = size;
    final random = math.Random(42);
    const particleCount = 2000;
    final points = Float32List(particleCount * 2);

    final rectWidth = size.width * 2;
    final rectHeight = rectWidth * 0.8;
    final centerX = (size.width - rectWidth) / 2 + rectWidth / 2;
    final centerY = size.height - rectHeight + rectHeight / 2;
    final radiusX = rectWidth / 2;
    final radiusY = rectHeight / 2;

    for (var i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * math.pi;
      final distribution = math.pow(random.nextDouble(), 5).toDouble();
      final sign = random.nextBool() ? 1 : -1;
      final thicknessOffset = distribution * 25.0 * sign;
      final nx = math.cos(angle);
      final ny = math.sin(angle);
      final px = centerX + (radiusX * nx) + (nx * thicknessOffset);
      final py = centerY + (radiusY * ny) + (ny * thicknessOffset);
      points[i * 2] = px;
      points[i * 2 + 1] = py;
    }
    _noisePoints = points;
  }

  @override
  Widget build(BuildContext context) {
    const downscaleFactor = 5.0;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final currentSize = Size(constraints.maxWidth, widget.height);
          _generateNoise(currentSize);

          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _StaticNoisePainter(points: _noisePoints!),
                  isComplex: true,
                ),
              ),

              Center(
                child: AnimatedBuilder(
                  animation: widget.animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: downscaleFactor,

                      filterQuality: FilterQuality.low,
                      child: SizedBox(
                        width: constraints.maxWidth / downscaleFactor,
                        height: widget.height / downscaleFactor,
                        child: CustomPaint(
                          painter: _FireGlowPainter(
                            pulse: widget.animation.value,
                            scale: 1.0 / downscaleFactor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              AnimatedBuilder(
                animation: widget.animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FireCorePainter(
                      pulse: widget.animation.value,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FireGlowPainter extends CustomPainter {
  _FireGlowPainter({required this.pulse, required this.scale});

  final double pulse;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0) return;

    final rectWidth = size.width * 2;
    final rectHeight = rectWidth * 0.8;
    final rect = Rect.fromLTWH(
      (size.width - rectWidth) / 2,
      size.height - rectHeight,
      rectWidth,
      rectHeight,
    );
    final gradientRect = Offset.zero & size;

    final paintObj = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    _drawLayer(
      canvas,
      paintObj,
      rect,
      gradientRect,
      const Color(0xFF5E1914),
      baseWidth: 60,
      baseBlur: 40,
      stops: const [0.0, 0.5, 1.0],
      widthMult: 5,
      blurMult: 5,
    );

    _drawLayer(
      canvas,
      paintObj,
      rect,
      gradientRect,
      const Color(0xFFFF4500),
      baseWidth: 20,
      baseBlur: 15,
      stops: const [0.0, 0.4, 0.9],
      widthMult: 8,
      blurMult: 3,
      opacityBase: 0.6,
      opacityMult: 0.5,
    );
  }

  // ignore: number_of_parameters
  void _drawLayer(
    Canvas canvas,
    Paint paintObj,
    Rect rect,
    Rect shaderRect,
    Color color, {
    required double baseWidth,
    required double baseBlur,
    required List<double> stops,
    required double widthMult,
    required double blurMult,
    double opacityBase = 1.0,
    double opacityMult = 0.0,
  }) {
    final opacity = (opacityBase + (opacityMult * pulse)).clamp(0.0, 1.0);
    if (opacity <= 0.01) return;

    paintObj
      ..strokeWidth = (baseWidth + (widthMult * pulse)) * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (baseBlur + (blurMult * pulse)) * scale)
      ..shader = ui.Gradient.radial(
        Offset(shaderRect.width / 2, shaderRect.height),
        shaderRect.height * 1.5,
        [
          color.withValues(alpha: 1.0 * opacity),
          color.withValues(alpha: 0.5 * opacity),
          color.withValues(alpha: 0),
        ],
        stops,
      );

    canvas.drawArc(rect, 0, math.pi, false, paintObj);
  }

  @override
  bool shouldRepaint(covariant _FireGlowPainter oldDelegate) =>
      oldDelegate.pulse != pulse || oldDelegate.scale != scale;
}

class _FireCorePainter extends CustomPainter {
  _FireCorePainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0) return;

    final rectWidth = size.width * 2;
    final rectHeight = rectWidth * 0.8;
    final rect = Rect.fromLTWH(
      (size.width - rectWidth) / 2,
      size.height - rectHeight,
      rectWidth,
      rectHeight,
    );
    final gradientRect = Offset.zero & size;

    final paintObj = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..blendMode = BlendMode.plus;

    _drawLayer(
      canvas,
      paintObj,
      rect,
      gradientRect,
      const Color(0xFFFFD700),
      baseWidth: 15,
      baseBlur: 6,
      stops: const [0.0, 0.2, 0.6],
      widthMult: 6,
      blurMult: 2,
    );

    _drawLayer(
      canvas,
      paintObj,
      rect,
      gradientRect,
      Colors.white,
      baseWidth: 6,
      baseBlur: 1,
      stops: const [0.0, 0.1, 0.6],
      widthMult: 2,
      blurMult: 1,
    );
  }

  // ignore: number_of_parameters
  void _drawLayer(
    Canvas canvas,
    Paint paintObj,
    Rect rect,
    Rect shaderRect,
    Color color, {
    required double baseWidth,
    required double baseBlur,
    required List<double> stops,
    required double widthMult,
    required double blurMult,
  }) {
    paintObj
      ..strokeWidth = baseWidth + (widthMult * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseBlur + (blurMult * pulse))
      ..shader = ui.Gradient.radial(
        Offset(shaderRect.width / 2, shaderRect.height),
        shaderRect.height * 1.5,
        [color, color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
        stops,
      );

    canvas.drawArc(rect, 0, math.pi, false, paintObj);
  }

  @override
  bool shouldRepaint(covariant _FireCorePainter oldDelegate) => oldDelegate.pulse != pulse;
}

class _StaticNoisePainter extends CustomPainter {
  _StaticNoisePainter({required this.points});
  final Float32List points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final gradient = ui.Gradient.radial(
      Offset(size.width / 2, size.height),
      size.width * 0.6,
      [const Color(0xFFFFD700).withValues(alpha: 0.9), const Color(0xFF8B0000).withValues(alpha: 0)],
      const [0.0, 1.0],
    );
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus
      ..shader = gradient;
    canvas.drawRawPoints(ui.PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant _StaticNoisePainter oldDelegate) => false;
}
