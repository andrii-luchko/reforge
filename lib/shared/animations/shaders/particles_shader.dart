import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParticlesShaderWidget extends StatefulWidget {
  const ParticlesShaderWidget({
    super.key,
    this.child,
    this.color = Colors.white,
    this.quantity = 10.0,
    this.speed = 0.01,
    this.particleSize = 0.01,
    this.alphaSpeed = 0.5,
  });

  final Widget? child;
  final Color color;
  final double quantity;
  final double speed;
  final double particleSize;
  final double alphaSpeed;

  @override
  State<ParticlesShaderWidget> createState() => _ParticlesShaderWidgetState();
}

class _ParticlesShaderWidgetState extends State<ParticlesShaderWidget> with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadShader());
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    unawaited(_ticker.start());
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset('shaders/particles.frag');
    setState(() {
      _program = program;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) return widget.child ?? const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ParticlesPainter(
            program: _program!,
            time: _time,
            color: widget.color,
            quantity: widget.quantity,
            speed: widget.speed,
            particleSize: widget.particleSize,
            alphaSpeed: widget.alphaSpeed,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({
    required this.program,
    required this.time,
    required this.color,
    required this.quantity,
    required this.speed,
    required this.particleSize,
    required this.alphaSpeed,
  });

  final ui.FragmentProgram program;
  final double time;
  final Color color;
  final double quantity;
  final double speed;
  final double particleSize;
  final double alphaSpeed;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader()
      // uSize (vec2)
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      // uTime
      ..setFloat(2, time)
      // uColor (vec3)
      ..setFloat(3, color.red / 255.0)
      ..setFloat(4, color.green / 255.0)
      ..setFloat(5, color.blue / 255.0)
      // uQuantity
      ..setFloat(6, quantity)
      // uSpeed
      ..setFloat(7, speed)
      // uSize
      ..setFloat(8, particleSize)
      // uAlphaSpeed
      ..setFloat(9, alphaSpeed);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.plus;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.color != color ||
        oldDelegate.quantity != quantity ||
        oldDelegate.speed != speed ||
        oldDelegate.particleSize != particleSize ||
        oldDelegate.alphaSpeed != alphaSpeed;
  }
}
