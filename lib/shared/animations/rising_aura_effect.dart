// ignore_for_file: no_empty_block
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RisingAuraEffect extends StatefulWidget {
  const RisingAuraEffect({
    required this.child,
    this.enabled = true,
    this.autoStopDuration = const Duration(minutes: 2),
    super.key,
    this.particleColor = const Color(0xFFD4AF37),
    this.particleCount = 50,
    this.particleSize = 0.5,
  });

  final Widget child;
  final bool enabled;
  final Duration? autoStopDuration;
  final Color particleColor;
  final int particleCount;
  final double particleSize;

  @override
  State<RisingAuraEffect> createState() => _RisingAuraEffectState();
}

class _RisingAuraEffectState extends State<RisingAuraEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ignore: avoid_multiple_declarations_per_line
  late Float32List _posX, _posY, _velX, _velY, _sizes, _lifeTimes, _maxLives, _phases;
  late Float32List _vertices;
  late Int32List _colors;
  late Uint16List _indices;

  final math.Random _rng = math.Random();
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initMemory();

    _controller = AnimationController(
      vsync: this,

      duration: widget.autoStopDuration ?? const Duration(days: 365),
    );

    _controller.addListener(_onFrame);

    if (widget.enabled) {
      _start();
    }
  }

  void _start() {
    _lastElapsed = Duration.zero;
    if (widget.autoStopDuration != null) {
      unawaited(_controller.forward(from: 0));
    } else {
      unawaited(_controller.repeat());
    }
  }

  void _initMemory() {
    final count = widget.particleCount;

    _posX = Float32List(count);
    _posY = Float32List(count);
    _velX = Float32List(count);
    _velY = Float32List(count);
    _sizes = Float32List(count);
    _phases = Float32List(count);
    _lifeTimes = Float32List(count);
    _maxLives = Float32List(count);

    _vertices = Float32List(count * 8);
    _colors = Int32List(count * 4);
    _indices = Uint16List(count * 6);

    for (var i = 0; i < count; i++) {
      final v = i * 4;
      final ix = i * 6;
      _indices[ix] = v;
      _indices[ix + 1] = v + 1;
      _indices[ix + 2] = v + 2;
      _indices[ix + 3] = v + 2;
      _indices[ix + 4] = v + 3;
      _indices[ix + 5] = v;

      _respawnParticle(i, const Size(1, 1), initial: true);
    }
  }

  void _onFrame() {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final size = renderBox.size;

    final currentElapsed = _controller.lastElapsedDuration ?? Duration.zero;
    final dt = (currentElapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = currentElapsed;

    if (dt > 0.1) return;

    var globalOpacity = 1.0;
    if (widget.autoStopDuration != null) {
      if (_controller.value > 0.9) {
        globalOpacity = (1.0 - _controller.value) * 10.0;
      }
    }

    final baseColorInt = widget.particleColor.toARGB32() & 0x00FFFFFF;
    final baseAlpha = (255 * globalOpacity).toInt();

    for (var i = 0; i < widget.particleCount; i++) {
      _lifeTimes[i] += dt;
      if (_lifeTimes[i] >= _maxLives[i]) {
        _respawnParticle(i, size);
      }

      if (_posX[i] <= 1.0 && _posY[i] <= 1.0 && _lifeTimes[i] > 0.1) {
        _posX[i] *= size.width;
        _posY[i] *= size.height;
      }

      _posX[i] += _velX[i] * dt + math.sin(currentElapsed.inMilliseconds / 500.0 + _phases[i]) * 20.0 * dt;
      _posY[i] += _velY[i] * dt;

      var pAlpha = (1.0 - (_lifeTimes[i] / _maxLives[i])).clamp(0.0, 1.0);
      if (_lifeTimes[i] < 0.5) pAlpha = (_lifeTimes[i] / 0.5).clamp(0.0, 1.0);

      final finalAlpha = (pAlpha * baseAlpha).toInt().clamp(0, 255);
      final color = (finalAlpha << 24) | baseColorInt;

      final r = _sizes[i];
      final x = _posX[i];
      final y = _posY[i];
      final v = i * 8;
      final c = i * 4;

      _vertices[v] = x - r;
      _vertices[v + 1] = y - r;
      _vertices[v + 2] = x + r;
      _vertices[v + 3] = y - r;
      _vertices[v + 4] = x + r;
      _vertices[v + 5] = y + r;
      _vertices[v + 6] = x - r;
      _vertices[v + 7] = y + r;

      _colors[c] = color;
      _colors[c + 1] = color;
      _colors[c + 2] = color;
      _colors[c + 3] = color;
    }

    setState(() {});
  }

  void _respawnParticle(int i, Size size, {bool initial = false}) {
    _maxLives[i] = 4.0 + _rng.nextDouble() * 4.0;
    _lifeTimes[i] = initial ? _rng.nextDouble() * _maxLives[i] : 0.0;

    if (initial) {
      _posX[i] = _rng.nextDouble();
      _posY[i] = _rng.nextDouble();
    } else {
      _posX[i] = _rng.nextDouble() * size.width;
      _posY[i] = size.height + 10;
    }

    _velY[i] = -15.0 - _rng.nextDouble() * 20.0;
    _velX[i] = (_rng.nextDouble() - 0.5) * 15.0;
    _sizes[i] = widget.particleSize + _rng.nextDouble();
    _phases[i] = _rng.nextDouble() * math.pi * 2;
  }

  @override
  void didUpdateWidget(RisingAuraEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _start();
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
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _VerticesPainter(
                    vertices: _vertices,
                    colors: _colors,
                    indices: _indices,
                  ),
                ),
              ),
            ),
          ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
}

class _VerticesPainter extends CustomPainter {
  _VerticesPainter({required this.vertices, required this.colors, required this.indices});

  final Float32List vertices;
  final Int32List colors;
  final Uint16List indices;

  @override
  void paint(Canvas canvas, Size size) {
    final vert = ui.Vertices.raw(ui.VertexMode.triangles, vertices, colors: colors, indices: indices);
    canvas.drawVertices(vert, BlendMode.dst, Paint()..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _VerticesPainter old) => true;
}
