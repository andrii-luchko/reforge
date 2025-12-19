import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireParticles extends StatefulWidget {
  const FireParticles({
    super.key,
    this.quantity = 100,
    this.startColor = const Color(0xFFFF6B35),
    this.endColor = const Color(0xFFFFAA00),
    this.minSize = 1.0,
    this.maxSize = 2.5,
    this.minSpeed = 0.8,
    this.maxSpeed = 2.5,
    this.fadeSpeed = 0.005,
  });

  final int quantity;
  final Color startColor;
  final Color endColor;
  final double minSize;
  final double maxSize;
  final double minSpeed;
  final double maxSpeed;
  final double fadeSpeed;

  @override
  State<FireParticles> createState() => _FireParticlesState();
}

class _FireParticlesState extends State<FireParticles> {
  late FireParticlesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FireParticlesController(
      quantity: widget.quantity,
      startColor: widget.startColor,
      endColor: widget.endColor,
      minSize: widget.minSize,
      maxSize: widget.maxSize,
      minSpeed: widget.minSpeed,
      maxSpeed: widget.maxSpeed,
      fadeSpeed: widget.fadeSpeed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_controller.canvasSize != size) {
          _controller.updateSize(size);
        }

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FireParticlesPainter(
                  particles: _controller.particles,
                  startColor: widget.startColor,
                  endColor: widget.endColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FireParticlesController extends ChangeNotifier {
  FireParticlesController({
    required this.quantity,
    required this.startColor,
    required this.endColor,
    required this.minSize,
    required this.maxSize,
    required this.minSpeed,
    required this.maxSpeed,
    required this.fadeSpeed,
  }) {
    _ticker = Ticker(_onTick)..start();
  }

  final int quantity;
  final Color startColor;
  final Color endColor;
  final double minSize;
  final double maxSize;
  final double minSpeed;
  final double maxSpeed;
  final double fadeSpeed;

  List<FireParticle> particles = [];
  Size canvasSize = Size.zero;
  final math.Random random = math.Random();
  late Ticker _ticker;

  void updateSize(Size size) {
    canvasSize = size;
    _initParticles();
  }

  void _initParticles() {
    particles.clear();
    for (var i = 0; i < quantity; i++) {
      particles.add(_createParticle(isInitial: true));
    }
  }

  FireParticle _createParticle({bool isInitial = false}) {
    final speed = minSpeed + random.nextDouble() * (maxSpeed - minSpeed);
    final isStreak = random.nextDouble() > 0.5;

    double y;
    double alpha;
    final targetAlpha = 0.4 + random.nextDouble() * 0.5;

    if (isInitial) {
      final randomValue = random.nextDouble();
      final biasedRandom = randomValue * randomValue;
      y = canvasSize.height * (1.0 - biasedRandom);

      final heightProgress = 1.0 - (y / canvasSize.height);
      alpha = targetAlpha * heightProgress * (0.6 + random.nextDouble() * 0.4);
    } else {
      y = canvasSize.height + random.nextDouble() * 30;
      alpha = 0.0;
    }

    return FireParticle(
      x: random.nextDouble() * canvasSize.width,
      y: y,
      size: minSize + random.nextDouble() * (maxSize - minSize),
      alpha: alpha,
      targetAlpha: targetAlpha,
      dx: (random.nextDouble() - 0.5) * 0.4,
      dy: -speed,
      lifeReduction: fadeSpeed * (0.7 + random.nextDouble() * 0.6),
      isStreak: isStreak,
      streakLength: isStreak ? (8.0 + random.nextDouble() * 12.0) : 0.0,
      rotation: random.nextDouble() * math.pi * 2,
    );
  }

  void _onTick(Duration elapsed) {
    if (canvasSize == Size.zero) return;

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];

      particle
        ..x += particle.dx
        ..y += particle.dy;

      if (particle.isStreak) {
        particle.rotation += 0.02;
      }

      particle.alpha -= particle.lifeReduction;

      if (particle.alpha < particle.targetAlpha && particle.y > canvasSize.height - 60) {
        particle.alpha += 0.08;
      }

      if (particle.alpha <= 0 || particle.y < -50) {
        particles[i] = _createParticle();
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class FireParticlesPainter extends CustomPainter {
  FireParticlesPainter({
    required this.particles,
    required this.startColor,
    required this.endColor,
  });

  final List<FireParticle> particles;
  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.alpha <= 0) continue;

      final colorProgress = (particle.alpha / particle.targetAlpha).clamp(0.0, 1.0);
      final color = Color.lerp(endColor, startColor, colorProgress)!;

      if (particle.isStreak) {
        _drawStreak(canvas, particle, color);
      } else {
        _drawDot(canvas, particle, color);
      }
    }
  }

  void _drawStreak(Canvas canvas, FireParticle particle, Color color) {
    canvas
      ..save()
      ..translate(particle.x, particle.y)
      ..rotate(particle.rotation);

    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: particle.alpha),
              color.withValues(alpha: particle.alpha * 0.3),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromLTWH(
              -particle.size * 0.5,
              0,
              particle.size,
              particle.streakLength,
            ),
          );

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -particle.size * 0.5,
        0,
        particle.size,
        particle.streakLength,
      ),
      Radius.circular(particle.size * 0.5),
    );

    canvas
      ..drawRRect(rrect, paint)
      ..restore();
  }

  void _drawDot(Canvas canvas, FireParticle particle, Color color) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: particle.alpha * 0.9),
              color.withValues(alpha: particle.alpha * 0.4),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(particle.x, particle.y),
              radius: particle.size * 2.5,
            ),
          );

    canvas.drawCircle(
      Offset(particle.x, particle.y),
      particle.size * 2.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(FireParticlesPainter oldDelegate) => true;
}

class FireParticle {
  FireParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.alpha,
    required this.targetAlpha,
    required this.dx,
    required this.dy,
    required this.lifeReduction,
    required this.isStreak,
    required this.streakLength,
    required this.rotation,
  });

  double x;
  double y;
  double size;
  double alpha;
  double targetAlpha;
  double dx;
  double dy;
  double lifeReduction;
  bool isStreak;
  double streakLength;
  double rotation;
}
