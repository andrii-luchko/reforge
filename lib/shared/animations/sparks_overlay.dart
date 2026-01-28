import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SparksOverlay extends StatefulWidget {
  const SparksOverlay({
    super.key,
    this.color = const Color(0xFFECE7DC),
    this.numberOfParticles = 1,
  });

  final Color color;
  final int numberOfParticles;

  @override
  State<SparksOverlay> createState() => _SparksOverlayState();
}

class _SparksOverlayState extends State<SparksOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late List<Spark> _particles;
  late Float32List _positions;
  late Int32List _colors;
  late Uint16List _indices;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initParticles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant SparksOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numberOfParticles != oldWidget.numberOfParticles) {
      _initParticles();
    }
  }

  void _initParticles() {
    _particles = List.generate(widget.numberOfParticles, (index) {
      return Spark(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: _random.nextDouble() * 0.01 + 0.1,
        size: _random.nextDouble() * 0.8 + 0.1,
        baseOpacity: _random.nextDouble() * 0.6 + 0.2,
        pulseOffset: _random.nextDouble() * 2 * math.pi,
        pulseSpeed: _random.nextDouble() * 3 + 1,
        swayOffset: _random.nextDouble() * 2 * math.pi,
      );
    });

    final count = widget.numberOfParticles;
    _positions = Float32List(count * 4 * 2);
    _colors = Int32List(count * 4);
    _indices = Uint16List(count * 6);

    for (var i = 0; i < count; i++) {
      final v = i * 4;
      final ind = i * 6;
      _indices[ind + 0] = v + 0;
      _indices[ind + 1] = v + 1;
      _indices[ind + 2] = v + 2;
      _indices[ind + 3] = v + 2;
      _indices[ind + 4] = v + 1;
      _indices[ind + 5] = v + 3;
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
        painter: _VerticesSparksPainter(
          animation: _controller,
          particles: _particles,
          positions: _positions,
          colors: _colors,
          indices: _indices,
          color: widget.color,
          random: _random,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class Spark {
  Spark({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.baseOpacity,
    required this.pulseOffset,
    required this.pulseSpeed,
    required this.swayOffset,
  });

  double x;
  double y;
  double speed;
  double size;
  double baseOpacity;
  double pulseOffset;
  double pulseSpeed;
  double swayOffset;
}

class _VerticesSparksPainter extends CustomPainter {
  _VerticesSparksPainter({
    required this.animation,
    required this.particles,
    required this.positions,
    required this.colors,
    required this.indices,
    required this.color,
    required this.random,
  }) : _paint = Paint()..style = PaintingStyle.fill,
       super(repaint: animation);

  final Animation<double> animation;
  final List<Spark> particles;
  final Float32List positions;
  final Int32List colors;
  final Uint16List indices;
  final Color color;
  final math.Random random;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    _updateParticlesAndBuffers(size);

    final vertices = ui.Vertices.raw(
      VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    canvas.drawVertices(vertices, BlendMode.srcOver, _paint);
  }

  void _updateParticlesAndBuffers(Size size) {
    final w = size.width;
    final h = size.height;
    final time = animation.value;
    final baseColorInt = color.toARGB32() & 0x00FFFFFF;

    for (var i = 0; i < particles.length; i++) {
      final spark = particles[i];

      spark
        ..y += spark.speed * 0.0005
        ..x += math.sin(time * 2 * math.pi + spark.swayOffset) * 0.002;

      if (spark.y > 1.1) {
        spark
          ..x = random.nextDouble()
          ..y = -0.2 - random.nextDouble() * 0.1
          ..speed = random.nextDouble() * 0.3 + 0.1;
      }

      final flicker = (math.sin(time * 10 * spark.pulseSpeed + spark.pulseOffset) + 1) / 2;
      final opacity = (spark.baseOpacity + (flicker * 0.3)).clamp(0.0, 1.0);
      final fadeOut = ((1.1 - spark.y) * 5.0).clamp(0.0, 1.0);
      final alphaInt = (opacity * fadeOut * 255).toInt().clamp(0, 255);
      final colorInt = (alphaInt << 24) | baseColorInt;

      final cx = spark.x * w;
      final cy = spark.y * h;
      final r = spark.size;

      final vIndex = i * 8;
      final cIndex = i * 4;

      // Top-Left
      positions[vIndex + 0] = cx - r;
      positions[vIndex + 1] = cy - r;
      colors[cIndex + 0] = colorInt;

      // Top-Right
      positions[vIndex + 2] = cx + r;
      positions[vIndex + 3] = cy - r;
      colors[cIndex + 1] = colorInt;

      // Bottom-Left
      positions[vIndex + 4] = cx - r;
      positions[vIndex + 5] = cy + r;
      colors[cIndex + 2] = colorInt;

      // Bottom-Right
      positions[vIndex + 6] = cx + r;
      positions[vIndex + 7] = cy + r;
      colors[cIndex + 3] = colorInt;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticesSparksPainter oldDelegate) {
    return false;
  }
}
