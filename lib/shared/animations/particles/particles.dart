// ignore_for_file: omit_local_variable_types

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A static particle generator using batch rendering for extreme performance.
/// Ideal for thousands of static particles.
class ParticlesWidget extends StatefulWidget {
  const ParticlesWidget({
    super.key,
    this.color = Colors.white,
    this.quantity = 100,
    this.size = 0.7,
  });

  final Color color;
  final int quantity;
  final double size;

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget> {
  late Float32List _positions;
  late Int32List _colors;
  late Uint16List _indices;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(ParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _initData();
    }
  }

  void _initData() {
    final math.Random rnd = math.Random();
    final int count = widget.quantity;

    // Using lists of exact sizes for low memory footprint
    _positions = Float32List(count * 4 * 2);
    _colors = Int32List(count * 4);
    _indices = Uint16List(count * 6);

    // Pre-calculate base RGB once
    final int rgb = widget.color.toARGB32() & 0x00FFFFFF;

    for (var i = 0; i < count; i++) {
      // Generate static properties
      final double normalizedX = rnd.nextDouble();
      final double normalizedY = rnd.nextDouble();

      // Calculate a static alpha to simulate twinkling stars that paused in time
      final double alphaNorm = 0.4 + rnd.nextDouble() * 0.6;
      final int alpha = (alphaNorm * 255).toInt().clamp(0, 255);
      final int colorInt = (alpha << 24) | rgb;

      // Notice we store normalized coordinates (0.0 to 1.0) directly in positions
      // We will scale them by screen size inside the painter.
      //
      // Layout per particle (quad):
      // Top-Left, Top-Right, Bottom-Right, Bottom-Left
      final int vIndex = i * 8;
      final int cIndex = i * 4;

      // We only store the base position and scale here.
      // The actual math happens during paint when size is known.
      for (var j = 0; j < 8; j += 2) {
        _positions[vIndex + j] = normalizedX;
        _positions[vIndex + j + 1] = normalizedY;
      }

      // Store the size in the Z/W coordinates mentally, or just use a uniform size.
      // For pure optimization, we'll apply size during the canvas draw.

      for (var c = 0; c < 4; c++) {
        _colors[cIndex + c] = colorInt;
      }

      final int ind = i * 6;
      final int v = i * 4;
      _indices[ind + 0] = v + 0;
      _indices[ind + 1] = v + 1;
      _indices[ind + 2] = v + 2;
      _indices[ind + 3] = v + 2;
      _indices[ind + 4] = v + 1;
      _indices[ind + 5] = v + 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BatchStarPainter(
          positions: _positions,
          colors: _colors,
          indices: _indices,
          baseSize: widget.size,
          quantity: widget.quantity,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BatchStarPainter extends CustomPainter {
  _BatchStarPainter({
    required this.positions,
    required this.colors,
    required this.indices,
    required this.baseSize,
    required this.quantity,
  });

  final Float32List positions;
  final Int32List colors;
  final Uint16List indices;
  final double baseSize;
  final int quantity;

  @override
  void paint(Canvas canvas, Size size) {
    final Float32List scaledPositions = Float32List(positions.length);
    final double w = size.width;
    final double h = size.height;
    final double r = baseSize;

    // Scale normalized coordinates to the actual canvas size
    for (var i = 0; i < quantity; i++) {
      final int vIndex = i * 8;
      final double cx = positions[vIndex] * w;
      final double cy = positions[vIndex + 1] * h;

      scaledPositions[vIndex + 0] = cx - r;
      scaledPositions[vIndex + 1] = cy - r;

      scaledPositions[vIndex + 2] = cx + r;
      scaledPositions[vIndex + 3] = cy - r;

      scaledPositions[vIndex + 4] = cx + r;
      scaledPositions[vIndex + 5] = cy + r;

      scaledPositions[vIndex + 6] = cx - r;
      scaledPositions[vIndex + 7] = cy + r;
    }

    final ui.Vertices vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      scaledPositions,
      colors: colors,
      indices: indices,
    );

    canvas.drawVertices(vertices, BlendMode.srcOver, Paint());
  }

  @override
  bool shouldRepaint(covariant _BatchStarPainter oldDelegate) {
    return oldDelegate.baseSize != baseSize || oldDelegate.quantity != quantity;
  }
}
