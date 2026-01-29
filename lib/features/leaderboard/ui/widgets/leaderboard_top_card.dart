import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';

class ImmortalForcesCard extends StatelessWidget {
  const ImmortalForcesCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double designWidth = 358;
    const double designHeight = 226;

    final silverGradient = LinearGradient(
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFF3E3D3A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final goldGradient = LinearGradient(
      colors: [
        Color(0xFFD4AF37),
        Color(0xFFF7EF8A),
        Color(0xFFB8860B),
        Color(0xFFD4AF37),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return AspectRatio(
      aspectRatio: designWidth / designHeight,
      child: FittedBox(
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Stack(
            alignment: .center,
            children: [
              Positioned.fill(
                child: SunRaysShaderWidget.leaderBoard(
                  color: const Color.fromARGB(255, 245, 192, 0),
                ),
              ),
              CustomPaint(
                painter: LeaderBoxPainter(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment(0.0, -0.8),
                      child: const GradientTextHeader(),
                    ),

                    Align(
                      alignment: Alignment(-0.9, -0.2),
                      child: SizedBox.fromSize(
                        size: Size(108, 32),
                        child: CustomPaint(
                          painter: RhombusPainter(),
                          child: Center(
                            child: Text(
                              'Might',
                              style: subheadH5Medium.copyWith(
                                color: context.appTheme.beige100,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.9, 0.2),
                      child: SizedBox.fromSize(
                        size: Size(108, 32),
                        child: CustomPaint(
                          painter: RhombusPainter(),
                          child: Center(
                            child: Text('Might', style: subheadH5Medium.copyWith(color: context.appTheme.beige100)),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.9, -0.2),
                      child: SizedBox.fromSize(
                        size: Size(108, 32),
                        child: CustomPaint(
                          painter: RhombusPainter(),
                          child: Center(
                            child: Text('Might', style: subheadH5Medium.copyWith(color: context.appTheme.beige100)),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-0.9, 0.2),
                      child: SizedBox.fromSize(
                        size: Size(108, 32),
                        child: CustomPaint(
                          painter: RhombusPainter(),
                          child: Center(
                            child: Text('Might', style: subheadH5Medium.copyWith(color: context.appTheme.beige100)),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: GradientLine(
                        gradient: LinearGradient(
                          colors: [
                            context.appTheme.beige100.withValues(alpha: 0),
                            context.appTheme.beige100.withValues(alpha: 0.2),
                            context.appTheme.beige100.withValues(alpha: 0.5),
                            context.appTheme.beige100,
                            context.appTheme.beige100.withValues(alpha: 0.5),
                            context.appTheme.beige100.withValues(alpha: 0.2),
                            context.appTheme.beige100.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),

                    Center(
                      child: LeaderBoardAvatar(
                        size: const Size(88, 88),
                        borderGradientColors: goldGradient,

                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                      ),
                    ),

                    Align(
                      alignment: Alignment(0.0, 0.8),
                      child: SizedBox.fromSize(
                        size: Size(108, 32),
                        child: CustomPaint(
                          painter: RhombusPainter(
                            strokeGradientColors: [
                              Color(0xFFD4AD38),
                              Color(0xFF5D4B17),
                            ],
                          ),
                          child: Center(
                            child: Text('Daizōshō', style: subheadH5Medium.copyWith(color: context.appTheme.beige100)),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-0.85, -0.9),
                      child: LeaderBoardAvatar(
                        size: const Size(64, 64),
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        borderGradientColors: silverGradient,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.85, 0.9),
                      child: LeaderBoardAvatar(
                        size: const Size(64, 64),
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        borderGradientColors: silverGradient,
                      ),
                    ),
                    Align(
                      alignment: Alignment(-0.85, 0.9),
                      child: LeaderBoardAvatar(
                        size: const Size(64, 64),
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        borderGradientColors: silverGradient,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.85, -0.9),
                      child: LeaderBoardAvatar(
                        size: const Size(64, 64),
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                        borderGradientColors: silverGradient,
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

class GradientLine extends StatelessWidget {
  const GradientLine({
    required this.gradient,
    super.key,
    this.height = 1.0,
    this.width,
    this.borderRadius,
  });

  final Gradient gradient;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
    );
  }
}

// --- Текст с градиентом ---
class GradientTextHeader extends StatelessWidget {
  const GradientTextHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Колонка не будет жадничать место
      crossAxisAlignment: CrossAxisAlignment.center, // Выравнивание самих виджетов
      children: [
        _buildGradientText("IMMORTAL", context),
        _buildGradientText("FORGES", context),
      ],
    );
  }

  Widget _buildGradientText(String text, BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFECE7DC), Color(0x00ECE7DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFamily: FontFamily.mechsuit,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class LeaderBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 358.0;
    final sy = size.height / 266.0;

    final matrix = Matrix4.diagonal3Values(sx, sy, 1);

    final path = Path()
      ..moveTo(8, 0.5)
      ..lineTo(100, 0.5)
      ..cubicTo(104.142, 0.5, 107.5, 3.85786, 107.5, 8)
      ..lineTo(107.5, 50.4375)
      ..cubicTo(107.5, 53.4419, 109.086, 56.2231, 111.672, 57.7529)
      ..lineTo(174.672, 95.0205)
      ..cubicTo(177.341, 96.5994, 180.659, 96.5994, 183.328, 95.0205)
      ..lineTo(246.328, 57.7529)
      ..cubicTo(248.914, 56.2231, 250.5, 53.4419, 250.5, 50.4375)
      ..lineTo(250.5, 8)
      ..cubicTo(250.5, 3.85786, 253.858, 0.5, 258, 0.5)
      ..lineTo(350, 0.5)
      ..cubicTo(354.142, 0.5, 357.5, 3.85786, 357.5, 8)
      ..lineTo(357.5, 258)
      ..cubicTo(357.5, 262.142, 354.142, 265.5, 350, 265.5)
      ..lineTo(261.5, 265.5)
      ..cubicTo(257.358, 265.5, 254, 262.142, 254, 258)
      ..lineTo(254, 215.9)
      ..cubicTo(254, 212.705, 252.208, 209.78, 249.362, 208.328)
      ..lineTo(182.85, 174.402)
      ..cubicTo(180.431, 173.169, 177.568, 173.165, 175.146, 174.392)
      ..lineTo(108.158, 208.333)
      ..cubicTo(105.301, 209.781, 103.5, 212.712, 103.5, 215.915)
      ..lineTo(103.5, 258)
      ..cubicTo(103.5, 262.142, 100.142, 265.5, 96, 265.5)
      ..lineTo(8, 265.5)
      ..cubicTo(3.85786, 265.5, 0.5, 262.142, 0.5, 258)
      ..lineTo(0.5, 8)
      ..cubicTo(0.5, 3.85786, 3.85786, 0.5, 8, 0.5)
      ..close();

    final scaledPath = path.transform(matrix.storage);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xff180D05);

    canvas.drawPath(scaledPath, fillPaint);

    final grad1Matrix = Matrix4.identity()
      ..setTranslationRaw(179, 118.5, 0)
      ..rotateZ(176.125 * math.pi / 180)
      ..multiply(Matrix4.diagonal3Values(125.788, 169.293, 1));

    final stroke1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * math.min(sx, sy)
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        [const Color(0xffECE7DC), const Color(0xffECE7DC).withValues(alpha: 0)],
        [0.0, 1.0],
        TileMode.clamp,
        grad1Matrix.storage,
      )
      ..color = const Color(0xff000000).withValues(alpha: 0.8);

    canvas.drawPath(scaledPath, stroke1Paint);

    final grad2Matrix = Matrix4.identity()
      ..setTranslationRaw(179, 133, 0)
      ..rotateZ(90 * math.pi / 180)
      ..multiply(Matrix4.diagonal3Values(133, 179, 1));

    final stroke2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * math.min(sx, sy)
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        [const Color(0xff2B221A).withValues(alpha: 0), const Color(0xff2B221A)],
        [0.0, 1.0],
        TileMode.clamp,
        grad2Matrix.storage,
      );

    canvas.drawPath(scaledPath, stroke2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RhombusPainter extends CustomPainter {
  RhombusPainter({
    this.backgroundColor = const Color(0xff180D05),

    this.radialGradientColors,

    this.strokeGradientColors,

    this.strokeWidth = 1.0,
  });

  final Color backgroundColor;
  final List<Color>? radialGradientColors;
  final List<Color>? strokeGradientColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 108.0;
    final sy = size.height / 34.0;
    final scaleMatrix = Matrix4.diagonal3Values(sx, sy, 1);

    final path = Path()
      ..moveTo(17.9195, 0.84071)
      ..cubicTo(18.6212, 0.29579, 19.4843, 0, 20.3728, 0)
      ..lineTo(87.5837, 0)
      ..cubicTo(88.4722, 0, 89.3354, 0.29579, 90.0371, 0.84071)
      ..lineTo(106.41, 13.555)
      ..cubicTo(108.472, 15.1564, 108.472, 18.2722, 106.41, 19.8736)
      ..lineTo(90.0371, 32.5879)
      ..cubicTo(89.3354, 33.1328, 88.4722, 33.4286, 87.5837, 33.4286)
      ..lineTo(20.3728, 33.4286)
      ..cubicTo(19.4843, 33.4286, 18.6212, 33.1328, 17.9195, 32.5879)
      ..lineTo(1.54664, 19.8736)
      ..cubicTo(-0.515568, 18.2722, -0.515566, 15.1564, 1.54664, 13.555)
      ..lineTo(17.9195, 0.84071)
      ..close();

    final scaledPath = path.transform(scaleMatrix.storage);

    final solidPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    canvas.drawPath(scaledPath, solidPaint);

    final radialMatrix = Matrix4(
      -107.792,
      -32.7671,
      0,
      0,
      110.764,
      -28.452,
      0,
      0,
      0,
      0,
      1,
      0,
      105.27,
      32.7671,
      0,
      1,
    );

    final scaledRadialMatrix = scaleMatrix.multiplied(radialMatrix);

    final radialColors =
        radialGradientColors ?? [const Color(0xff4A2105).withValues(alpha: 0), const Color(0xff4A2105)];

    final radialPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1,
        radialColors,
        [0.53, 1.0],
        TileMode.clamp,
        scaledRadialMatrix.storage,
      );

    canvas.drawPath(scaledPath, radialPaint);

    final strokeColors =
        strokeGradientColors ??
        [const Color(0xffECE7DC).withValues(alpha: 0.6), const Color(0xffECE7DC).withValues(alpha: 0)];

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = ui.Gradient.linear(
        const Offset(11.3717, 0),
        const Offset(95.5656, 53.8511),
        strokeColors,
        [0.0, 1.0],
        TileMode.clamp,
        scaleMatrix.storage,
      );

    canvas.drawPath(scaledPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant RhombusPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radialGradientColors != radialGradientColors ||
        oldDelegate.strokeGradientColors != strokeGradientColors;
  }
}
