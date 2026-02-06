import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FireParticles extends StatefulWidget {
  const FireParticles({
    super.key,
    this.quantity = 50,
    this.startColor = const Color(0xFFFF6B35),
    this.endColor = const Color(0xFFFFAA00),
    this.minSize = 1.0,
    this.maxSize = 2.5,
    this.minSpeed = 0.8,
    this.maxSpeed = 1.5,
    this.fadeSpeed = 0.01,
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

class _FireParticlesState extends State<FireParticles> with SingleTickerProviderStateMixin {
  late FireParticlesController _controller;
  ui.Image? _dotImage;
  ui.Image? _streakImage;
  bool _assetsLoaded = false;

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
      vsync: this,
    );
    unawaited(_generateAssets());
  }

  Future<void> _generateAssets() async {
    const size = 64.0;

    final dotRecorder = ui.PictureRecorder();
    final dotCanvas = Canvas(dotRecorder);
    final dotPaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(size / 2, size / 2),
        size / 2,
        [
          Colors.white,
          Colors.white.withValues(alpha: .7),
          Colors.white.withValues(alpha: 0.3),
        ],
        [0.0, 0.6, 1.0],
      );
    dotCanvas.drawCircle(const Offset(size / 2, size / 2), size / 2, dotPaint);
    final dotPicture = dotRecorder.endRecording();
    _dotImage = await dotPicture.toImage(size.toInt(), size.toInt());
    dotPicture.dispose();

    final streakRecorder = ui.PictureRecorder();
    final streakCanvas = Canvas(streakRecorder);
    const streakRect = Rect.fromLTWH(0, 0, size / 2, size);
    final streakPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(0, size),
        [
          Colors.white,
          Colors.white.withValues(alpha: .7),
          Colors.white.withValues(alpha: 0.3),
        ],
        [0.0, 0.5, 1.0],
      );
    streakCanvas.drawRRect(
      RRect.fromRectAndRadius(streakRect, const Radius.circular(size / 8)),
      streakPaint,
    );
    final streakPicture = streakRecorder.endRecording();
    _streakImage = await streakPicture.toImage((size / 2).toInt(), size.toInt());
    streakPicture.dispose();

    if (mounted) {
      setState(() {
        _assetsLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotImage?.dispose();
    _streakImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_assetsLoaded) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _controller.updateSize(size);

        return RepaintBoundary(
          child: CustomPaint(
            painter: FireParticlesPainter(
              controller: _controller,
              dotImage: _dotImage!,
              streakImage: _streakImage!,
            ),
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
    required TickerProvider vsync,
  }) {
    _startR = (startColor.r * 255.0).round().clamp(0, 255).toDouble();
    _startG = (startColor.g * 255.0).round().clamp(0, 255).toDouble();
    _startB = (startColor.b * 255.0).round().clamp(0, 255).toDouble();
    _endR = (endColor.r * 255.0).round().clamp(0, 255).toDouble();
    _endG = (endColor.g * 255.0).round().clamp(0, 255).toDouble();
    _endB = (endColor.b * 255.0).round().clamp(0, 255).toDouble();

    // ignore: discarded_futures
    _ticker = vsync.createTicker(_onTick)..start();
  }

  final int quantity;
  final Color startColor;
  final Color endColor;
  final double minSize;
  final double maxSize;
  final double minSpeed;
  final double maxSpeed;
  final double fadeSpeed;

  late final double _startR;
  late final double _startG;
  late final double _startB;
  late final double _endR;
  late final double _endG;
  late final double _endB;

  List<FireParticle> particles = [];
  Size canvasSize = Size.zero;
  final math.Random random = math.Random();
  late Ticker _ticker;

  final List<FireParticle> _particlePool = [];

  void updateSize(Size size) {
    if (canvasSize == size) return;
    canvasSize = size;
    _initParticles();
  }

  void _initParticles() {
    particles
      ..forEach(_particlePool.add)
      ..clear();

    for (var i = 0; i < quantity; i++) {
      particles.add(_createParticle(isInitial: true));
    }
  }

  FireParticle _createParticle({bool isInitial = false}) {
    final particle = _particlePool.isNotEmpty ? _particlePool.removeLast() : FireParticle();

    final speed = minSpeed + random.nextDouble() * (maxSpeed - minSpeed);
    final isStreak = random.nextDouble() > 0.5;

    double y;
    double alpha;
    final targetAlpha = 1.0 + random.nextDouble();

    if (isInitial && canvasSize != Size.zero) {
      final randomValue = random.nextDouble();
      final biasedRandom = randomValue * randomValue;
      y = canvasSize.height * (1.0 - biasedRandom);
      final heightProgress = 1.0 - (y / canvasSize.height);
      alpha = targetAlpha * heightProgress * (0.6 + random.nextDouble() * 0.4);
    } else {
      y = canvasSize.height + random.nextDouble() * 30.0;
      alpha = 0.0;
    }

    particle
      ..x = random.nextDouble() * canvasSize.width
      ..y = y
      ..size = minSize + random.nextDouble() * (maxSize - minSize)
      ..baseSize = particle.size
      ..alpha = alpha
      ..targetAlpha = targetAlpha
      ..dx = (random.nextDouble() - 0.5) * 0.4
      ..dy = -speed
      ..lifeReduction = fadeSpeed * (0.7 + random.nextDouble() * 0.6)
      ..isStreak = isStreak
      ..streakLength = isStreak ? (8.0 + random.nextDouble() * 12.0) : 0.0
      ..rotation = random.nextDouble() * math.pi * 2.0
      ..rotationSpeed = (random.nextDouble() - 0.5) * 0.04
      ..turbulence = random.nextDouble() * 0.3
      ..turbulencePhase = random.nextDouble() * math.pi * 2.0
      ..flickerSpeed = 0.1 + random.nextDouble() * 0.15
      ..flickerPhase = random.nextDouble() * math.pi * 2.0
      ..heatGlow = random.nextDouble()
      ..time = 0.0;

    return particle;
  }

  void _onTick(Duration elapsed) {
    if (canvasSize == Size.zero) return;

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i]..time += 0.016;

      final turbulenceX = math.sin(particle.time * 2.0 + particle.turbulencePhase) * particle.turbulence;
      final turbulenceY = math.cos(particle.time * 1.5 + particle.turbulencePhase) * particle.turbulence * 0.5;

      particle
        ..x += particle.dx + turbulenceX
        ..y += particle.dy + turbulenceY;

      particle.isStreak
          ? particle.rotation += particle.rotationSpeed
          : particle.rotation += particle.rotationSpeed * 0.5;

      final flicker = math.sin(particle.time * 10.0 * particle.flickerSpeed + particle.flickerPhase);
      const flickerAmount = 0.15;

      particle
        ..alpha -= particle.lifeReduction
        ..alpha += flicker * flickerAmount * particle.alpha.clamp(0.0, 1.0);

      final pulse = math.sin(particle.time * 8.0 + particle.flickerPhase) * 0.1;
      particle.size = particle.baseSize * (1.0 + pulse);

      if (particle.alpha < particle.targetAlpha && particle.y > canvasSize.height - 60.0) {
        particle.alpha += 0.08;
      }

      final heightProgress = 1.0 - (particle.y / canvasSize.height).clamp(0.0, 1.0);
      final sizeBoost = 1.0 + heightProgress * 0.4;
      particle.size *= sizeBoost;

      if (particle.alpha <= 0.0 || particle.y < -50.0) {
        particles[i] = _createParticle();
      }
    }

    notifyListeners();
  }

  Color lerpColor(double t) {
    final clampedT = t.clamp(0.0, 1.0);
    return Color.fromARGB(
      255,
      (_endR + (_startR - _endR) * clampedT).round(),
      (_endG + (_startG - _endG) * clampedT).round(),
      (_endB + (_startB - _endB) * clampedT).round(),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _particlePool.clear();
    super.dispose();
  }
}

class FireParticlesPainter extends CustomPainter {
  FireParticlesPainter({
    required this.controller,
    required this.dotImage,
    required this.streakImage,
  }) : super(repaint: controller);

  final FireParticlesController controller;
  final ui.Image dotImage;
  final ui.Image streakImage;

  final Paint _paint = Paint()..isAntiAlias = true;
  final Matrix4 _matrix = Matrix4.identity();

  static double? _cachedDotW;
  static double? _cachedDotH;
  static double? _cachedStreakW;
  static double? _cachedStreakH;

  @override
  void paint(Canvas canvas, Size size) {
    final particles = controller.particles;

    _cachedDotW ??= dotImage.width.toDouble();
    _cachedDotH ??= dotImage.height.toDouble();
    _cachedStreakW ??= streakImage.width.toDouble();
    _cachedStreakH ??= streakImage.height.toDouble();

    final dotW = _cachedDotW!;
    final dotH = _cachedDotH!;
    final streakW = _cachedStreakW!;
    final streakH = _cachedStreakH!;

    _sortParticlesByDepth(particles);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      if (particle.alpha <= 0.0) continue;

      final colorProgress = (particle.alpha / particle.targetAlpha).clamp(0.0, 1.0);
      final color = controller.lerpColor(colorProgress);

      final heightFactor = (1.0 - (particle.y / size.height)).clamp(0.0, 1.0);
      final heatIntensity = heightFactor * particle.heatGlow * 0.3;

      final colorRed = (color.r * 255.0).round().clamp(0, 255);
      final colorGreen = (color.g * 255.0).round().clamp(0, 255);
      final colorBlue = (color.b * 255.0).round().clamp(0, 255);
      final finalColor = Color.fromARGB(
        (particle.alpha * 255).clamp(0, 255).toInt(),
        (colorRed + (255 - colorRed) * heatIntensity * 0.5).clamp(0, 255).toInt(),
        (colorGreen * (1.0 - heatIntensity * 0.3)).clamp(0, 255).toInt(),
        (colorBlue * (1.0 - heatIntensity * 0.5)).clamp(0, 255).toInt(),
      );

      _paint.colorFilter = ColorFilter.mode(finalColor, BlendMode.modulate);

      if (particle.isStreak) {
        final scaleX = particle.size / (streakW / 2.0);
        final scaleY = particle.streakLength / streakH;

        _matrix
          ..setIdentity()
          // ignore: deprecated_member_use
          ..translate(particle.x, particle.y)
          ..rotateZ(particle.rotation)
          // ignore: deprecated_member_use
          ..scale(scaleX, scaleY)
          // ignore: deprecated_member_use
          ..translate(-streakW / 2.0);

        canvas
          ..save()
          ..transform(_matrix.storage)
          ..drawImage(streakImage, Offset.zero, _paint)
          ..restore();
      } else {
        final scale = (particle.size * 2.5) / (dotW / 2.0);

        _matrix
          ..setIdentity()
          // ignore: deprecated_member_use
          ..translate(particle.x, particle.y)
          // ignore: deprecated_member_use
          ..scale(scale, scale)
          // ignore: deprecated_member_use
          ..translate(-dotW / 2.0, -dotH / 2.0);

        canvas
          ..save()
          ..transform(_matrix.storage)
          ..drawImage(dotImage, Offset.zero, _paint)
          ..restore();
      }
    }
  }

  void _sortParticlesByDepth(List<FireParticle> particles) {
    for (var i = 1; i < particles.length; i++) {
      final particle = particles[i];
      var j = i - 1;

      var maxChecks = 5;
      while (j >= 0 && maxChecks > 0 && particles[j].y < particle.y) {
        particles[j + 1] = particles[j];
        j--;
        maxChecks--;
      }
      particles[j + 1] = particle;
    }
  }

  @override
  bool shouldRepaint(covariant FireParticlesPainter oldDelegate) {
    return true;
  }
}

class FireParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  double baseSize = 0;
  double alpha = 0;
  double targetAlpha = 0;
  double dx = 0;
  double dy = 0;
  double lifeReduction = 0;
  bool isStreak = false;
  double streakLength = 0;
  double rotation = 0;
  double rotationSpeed = 0;
  double turbulence = 0;
  double turbulencePhase = 0;
  double flickerSpeed = 0;
  double flickerPhase = 0;
  double heatGlow = 0;
  double time = 0;
}
