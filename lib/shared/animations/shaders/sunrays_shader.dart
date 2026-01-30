import 'dart:async';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'package:reforge/app/di/service_injector.dart' as di;

class SunRaysShaderWidget extends StatefulWidget {
  const SunRaysShaderWidget({
    super.key,

    this.child,

    this.color = Colors.amber,

    this.intensity = 1.2,

    this.alignment = Alignment.center,

    this.rayLength = 0.18,

    this.density = 10.0,
  });

  factory SunRaysShaderWidget.fromTop({required Color color}) {
    return SunRaysShaderWidget(
      color: color,

      rayLength: 0.1,

      alignment: const Alignment(0, -0.25),
    );
  }

  factory SunRaysShaderWidget.home({required Color color}) {
    return SunRaysShaderWidget(
      color: color,

      rayLength: 0.11,

      alignment: const Alignment(-0.3, -0.19),
    );
  }

  factory SunRaysShaderWidget.fromBehind({required Color color}) {
    return SunRaysShaderWidget(
      color: color,

      intensity: 3,

      rayLength: 0.11,

      density: 3,
    );
  }

  factory SunRaysShaderWidget.leaderBoard({required Color color}) {
    return SunRaysShaderWidget(
      color: color,

      intensity: 0.2,

      rayLength: 0.07,

      density: 3,
    );
  }
  final Widget? child;

  final Color color;

  final double intensity;

  final Alignment alignment;

  final double rayLength;

  final double density;

  @override
  State<SunRaysShaderWidget> createState() => _SunRaysShaderWidgetState();
}

class _SunRaysShaderWidgetState extends State<SunRaysShaderWidget> with SingleTickerProviderStateMixin, RouteAware {
  ui.FragmentProgram? _program;
  Ticker? _ticker;

  final ValueNotifier<double> _timeNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    unawaited(_loadShader());

    _ticker = createTicker((elapsed) {
      final now = elapsed.inMilliseconds / 1000.0;

      _timeNotifier.value = now % 10000.0;
    });

    unawaited(_ticker?.start());
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/sun_rays.frag');
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      debugPrint('Shader error: $e');
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     _ticker?.stop();
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (ModalRoute.of(context)?.isCurrent ?? false) {
  //       unawaited(_ticker?.start());
  //     }
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      di.getIt<RouteObserver<ModalRoute<void>>>().subscribe(this, route);
    }
  }

  @override
  void dispose() {
    if (di.getIt.isRegistered<RouteObserver<ModalRoute<void>>>()) {
      di.getIt<RouteObserver<ModalRoute<void>>>().unsubscribe(this);
    }
    _ticker?.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (_ticker?.isActive ?? false) _ticker?.stop();
  }

  @override
  void didPopNext() {
    if (!(_ticker?.isActive ?? false)) unawaited(_ticker?.start());
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return widget.child ?? const SizedBox.shrink();
    }

    const downscale = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final smallWidth = constraints.maxWidth / downscale;
        final smallHeight = constraints.maxHeight / downscale;

        return Transform.scale(
          scale: downscale,
          child: RepaintBoundary(
            child: SizedBox(
              width: smallWidth,
              height: smallHeight,
              child: CustomPaint(
                painter: _ShaderPainter(
                  program: _program!,
                  timeNotifier: _timeNotifier,
                  color: widget.color,
                  intensity: widget.intensity,
                  focalPoint: widget.alignment,
                  rayLength: widget.rayLength,
                  density: widget.density,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.program,
    required this.timeNotifier,
    required this.color,
    required this.intensity,
    required this.focalPoint,
    required this.rayLength,
    required this.density,
  }) : super(repaint: timeNotifier);

  final ui.FragmentProgram program;
  final ValueNotifier<double> timeNotifier;
  final Color color;
  final double intensity;
  final Alignment focalPoint;
  final double rayLength;
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    final time = timeNotifier.value;

    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, (color.r * 255.0).round().clamp(0, 255) / 255.0)
      ..setFloat(4, (color.g * 255.0).round().clamp(0, 255) / 255.0)
      ..setFloat(5, (color.b * 255.0).round().clamp(0, 255) / 255.0)
      ..setFloat(6, intensity);

    final originX = (focalPoint.x + 1) / 2;
    final originY = (focalPoint.y + 1) / 2;

    shader
      ..setFloat(7, originX)
      ..setFloat(8, originY)
      ..setFloat(9, rayLength)
      ..setFloat(10, density);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return oldDelegate.focalPoint != focalPoint ||
        oldDelegate.color != color ||
        oldDelegate.rayLength != rayLength ||
        oldDelegate.density != density ||
        oldDelegate.program != program;
  }
}
