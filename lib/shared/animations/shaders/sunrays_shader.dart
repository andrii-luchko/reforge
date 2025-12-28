import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SunRaysShaderWidget extends StatefulWidget {
  const SunRaysShaderWidget({
    super.key,
    this.child,
    this.color = Colors.amber,
    this.intensity = 1.2,
    this.alignment = const Alignment(0, -1.5),
    this.rayLength = 0.5,
    this.density = 10.0,
  });

  final Widget? child;
  final Color color;
  final double intensity;
  final Alignment alignment;
  final double rayLength;
  final double density;

  @override
  State<SunRaysShaderWidget> createState() => _SunRaysShaderWidgetState();
}

class _SunRaysShaderWidgetState extends State<SunRaysShaderWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ui.FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    unawaited(_loadShader());
    _ticker = createTicker((elapsed) {
      final newTime = elapsed.inMilliseconds / 1000.0;
      if ((newTime - _time).abs() > 0.033) {
        setState(() {
          _time = newTime;
        });
      }
    });
    unawaited(_ticker.start());
  }

  Future<void> _loadShader() async {
    final program = await ui.FragmentProgram.fromAsset('shaders/sun_rays.frag');
    setState(() {
      _program = program;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ticker.stop();
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_ticker.start());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return widget.child ?? const SizedBox.shrink();
    }
    const downscale = 2.0;
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.scale(
            scale: downscale,
            child: SizedBox(
              width: constraints.maxWidth / downscale,
              height: constraints.maxHeight / downscale,
              child: CustomPaint(
                painter: _ShaderPainter(
                  program: _program!,
                  time: _time,
                  color: widget.color,
                  intensity: widget.intensity,
                  focalPoint: widget.alignment,
                  rayLength: widget.rayLength,
                  density: widget.density,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.program,
    required this.time,
    required this.color,
    required this.intensity,
    required this.focalPoint,
    required this.rayLength,
    required this.density,
  });

  final ui.FragmentProgram program;
  final double time;
  final Color color;
  final double intensity;
  final Alignment focalPoint;
  final double rayLength;
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader()
      // 0, 1. Size
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      // 2. Time
      ..setFloat(2, time)
      // 3, 4, 5. Color
      ..setFloat(3, color.red / 255.0)
      ..setFloat(4, color.green / 255.0)
      ..setFloat(5, color.blue / 255.0)
      // 6. Intensity
      ..setFloat(6, intensity);

    final originX = (focalPoint.x + 1) / 2;
    final originY = (focalPoint.y + 1) / 2;

    shader
      // 7, 8. Origin
      ..setFloat(7, originX)
      ..setFloat(8, originY)
      // 9. Ray Length
      ..setFloat(9, rayLength)
      // 10. Density
      ..setFloat(10, density);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.focalPoint != focalPoint ||
        oldDelegate.color != color ||
        oldDelegate.rayLength != rayLength ||
        oldDelegate.density != density;
  }
}
