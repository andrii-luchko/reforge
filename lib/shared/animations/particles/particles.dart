// ignore_for_file: omit_local_variable_types

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ParticlesWidget extends StatefulWidget {
  const ParticlesWidget({
    super.key,
    this.color = Colors.white,
    this.quantity = 100,
    this.speed = 0.1,
    this.flickerSpeed = 0.1,
    this.size = 1.0,
    this.enabled = false,
  });

  final Color color;
  final int quantity;
  final double speed;
  final double flickerSpeed;
  final double size;
  final bool enabled;

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late List<_StarData> _stars;
  late Float32List _positions;
  late Int32List _colors;
  late Uint16List _indices;

  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _initData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enabled) {
      unawaited(_controller.repeat());
    }
  }

  void _initData() {
    _stars = List.generate(widget.quantity, (i) {
      final angle = _rnd.nextDouble() * 2 * math.pi;
      return _StarData(
        x: _rnd.nextDouble(),
        y: _rnd.nextDouble(),
        dirX: math.cos(angle),
        dirY: math.sin(angle),
        flickerPhase: _rnd.nextDouble() * 2 * math.pi,
        baseFlickerFrequency: 2.0 + _rnd.nextDouble() * 4.0,
        sizeScale: 0.5 + _rnd.nextDouble() * 0.5,
      );
    });

    final int count = widget.quantity;
    _positions = Float32List(count * 4 * 2);
    _colors = Int32List(count * 4);
    _indices = Uint16List(count * 6);

    for (var i = 0; i < count; i++) {
      final int v = i * 4;
      final int ind = i * 6;
      _indices[ind + 0] = v + 0;
      _indices[ind + 1] = v + 1;
      _indices[ind + 2] = v + 2;
      _indices[ind + 3] = v + 2;
      _indices[ind + 4] = v + 1;
      _indices[ind + 5] = v + 3;
    }
  }

  @override
  void didUpdateWidget(ParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.quantity != oldWidget.quantity) {
      _initData();
    }

    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        unawaited(_controller.repeat());
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _StarDustPainter(
          animation: _controller,
          stars: _stars,
          positions: _positions,
          colors: _colors,
          indices: _indices,
          baseColor: widget.color,
          baseSize: widget.size,
          speedMultiplier: widget.speed,
          flickerMultiplier: widget.flickerSpeed,
          isAnimating: widget.enabled,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StarData {
  _StarData({
    required this.x,
    required this.y,
    required this.dirX,
    required this.dirY,
    required this.flickerPhase,
    required this.baseFlickerFrequency,
    required this.sizeScale,
  });

  double x;
  double y;
  final double dirX;
  final double dirY;
  final double flickerPhase;
  final double baseFlickerFrequency;
  final double sizeScale;
}

class _StarDustPainter extends CustomPainter {
  _StarDustPainter({
    required this.animation,
    required this.stars,
    required this.positions,
    required this.colors,
    required this.indices,
    required this.baseColor,
    required this.baseSize,
    required this.speedMultiplier,
    required this.flickerMultiplier,
    required this.isAnimating,
  }) : _paint = Paint()..style = PaintingStyle.fill,
       super(repaint: isAnimating ? animation : null);

  final Animation<double> animation;
  final List<_StarData> stars;
  final Float32List positions;
  final Int32List colors;
  final Uint16List indices;
  final Color baseColor;
  final double baseSize;
  final double speedMultiplier;
  final double flickerMultiplier;
  final bool isAnimating;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final int rgb = baseColor.toARGB32() & 0x00FFFFFF;

    final double time = isAnimating ? DateTime.now().millisecondsSinceEpoch / 1000.0 : 0.0;

    final double moveStep = isAnimating ? 0.0002 * speedMultiplier : 0.0;

    for (var i = 0; i < stars.length; i++) {
      final star = stars[i];

      if (isAnimating && moveStep != 0) {
        star
          ..x += star.dirX * moveStep
          ..y += star.dirY * moveStep;

        if (star.x < 0) star.x += 1.0;
        if (star.x > 1) star.x -= 1.0;
        if (star.y < 0) star.y += 1.0;
        if (star.y > 1) star.y -= 1.0;
      }

      final double currentFrequency = star.baseFlickerFrequency * flickerMultiplier;

      final double flicker = math.sin(time * currentFrequency + star.flickerPhase);
      final double alphaNorm = flicker * 0.4 + 0.6;

      final int alpha = (alphaNorm * 255).toInt().clamp(0, 255);
      final int colorInt = (alpha << 24) | rgb;

      final double cx = star.x * w;
      final double cy = star.y * h;
      final double r = baseSize * star.sizeScale;

      final int vIndex = i * 8;
      final int cIndex = i * 4;

      positions[vIndex + 0] = cx - r;
      positions[vIndex + 1] = cy - r;
      colors[cIndex + 0] = colorInt;

      positions[vIndex + 2] = cx + r;
      positions[vIndex + 3] = cy - r;
      colors[cIndex + 1] = colorInt;

      positions[vIndex + 4] = cx + r;
      positions[vIndex + 5] = cy + r;
      colors[cIndex + 2] = colorInt;

      positions[vIndex + 6] = cx - r;
      positions[vIndex + 7] = cy + r;
      colors[cIndex + 3] = colorInt;
    }

    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    canvas.drawVertices(vertices, BlendMode.plus, _paint);
  }

  @override
  bool shouldRepaint(covariant _StarDustPainter oldDelegate) {
    return oldDelegate.isAnimating != isAnimating ||
        oldDelegate.speedMultiplier != speedMultiplier ||
        oldDelegate.flickerMultiplier != flickerMultiplier ||
        oldDelegate.baseColor != baseColor ||
        (isAnimating && oldDelegate.animation.value != animation.value);
  }
}
