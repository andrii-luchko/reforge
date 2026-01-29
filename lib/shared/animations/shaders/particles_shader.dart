import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ParticlesShaderWidget extends StatefulWidget {
  const ParticlesShaderWidget({
    super.key,
    this.color = Colors.white,
    this.quantity = 100.0,
    this.speed = 0.05,
    this.particleSize = 0.00005,
    this.alphaSpeed = 0.5,
  });

  final Color color;
  final double quantity;
  final double speed;
  final double particleSize;
  final double alphaSpeed;

  @override
  State<ParticlesShaderWidget> createState() => _ParticlesShaderWidgetState();
}

class _ParticlesShaderWidgetState extends State<ParticlesShaderWidget> {
  ui.FragmentShader? _shader;
  Timer? _timer;

  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);

  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_loadShader());

    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      final elapsed = DateTime.now().difference(_startTime);

      _timeNotifier.value = elapsed.inMilliseconds / 1000.0;
    });
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset('shaders/particles.frag');
    if (mounted) {
      setState(() {
        _shader = program.fragmentShader();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) return const SizedBox.shrink();

    const downscale = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth / downscale;
        final h = constraints.maxHeight / downscale;

        return Transform.scale(
          scale: downscale,
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            child: SizedBox(
              width: w,
              height: h,
              child: CustomPaint(
                painter: _ParticlesPainter(
                  shader: _shader!,
                  timeNotifier: _timeNotifier,
                  color: widget.color,
                  quantity: widget.quantity,
                  speed: widget.speed,
                  particleSize: widget.particleSize / downscale,
                  alphaSpeed: widget.alphaSpeed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({
    required this.shader,
    required this.timeNotifier,
    required this.color,
    required this.quantity,
    required this.speed,
    required this.particleSize,
    required this.alphaSpeed,
  }) : super(repaint: timeNotifier);

  final ui.FragmentShader shader;
  final ValueNotifier<double> timeNotifier;
  final Color color;
  final double quantity;
  final double speed;
  final double particleSize;
  final double alphaSpeed;

  @override
  void paint(Canvas canvas, Size size) {
    final colorRed = (color.r * 255.0).round().clamp(0, 255);
    final colorGreen = (color.g * 255.0).round().clamp(0, 255);
    final colorBlue = (color.b * 255.0).round().clamp(0, 255);
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, timeNotifier.value)
      ..setFloat(3, colorRed / 255.0)
      ..setFloat(4, colorGreen / 255.0)
      ..setFloat(5, colorBlue / 255.0)
      ..setFloat(6, quantity)
      ..setFloat(7, speed)
      ..setFloat(8, particleSize)
      ..setFloat(9, alphaSpeed);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.quantity != quantity || oldDelegate.speed != speed;
  }
}
