import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/workout_common/ui/widgets/gloving_arc.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/animations/sparks_overlay.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class StartRunningPage extends StatefulWidget {
  const StartRunningPage({super.key});

  @override
  State<StartRunningPage> createState() => _StartRunningPageState();
}

class _StartRunningPageState extends State<StartRunningPage> with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _breatheAnimation;

  Timer? _timer;
  int _currentCount = 5;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      // ignore: discarded_futures
    )..repeat(reverse: true);

    _breatheAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutSine,
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 0) {
        setState(() {
          _currentCount--;
        });
        unawaited(HapticFeedback.mediumImpact());
      } else {
        timer.cancel();
        _onCountdownFinished();
      }
    });
  }

  void _onCountdownFinished() {
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultBackground(
        additionalAnimationsOnTop: [
          Positioned.fill(
            child: SunRaysShaderWidget.fromTop(color: context.appTheme.orange500),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height / 1.7,
              child: const SparksOverlay(
                color: Color.fromARGB(255, 255, 149, 0),
                numberOfParticles: 150,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.2),
            child: GlowingArc(
              animation: _breatheAnimation,
            ),
          ),
        ],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final inAnimation = Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: inAnimation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: CounterText(
                    key: ValueKey<int>(_currentCount),
                    textContent: '$_currentCount',
                  ),
                ),
                const SizedBox(height: 8),
                const CenteredTitleSection(
                  title: 'Get Ready to Run',
                  subtitle:
                      'Your session starts in a moment. Focus on your breath, set your pace, and prepare to begin as the countdown hits zero.',
                ),

                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CounterText extends StatefulWidget {
  const CounterText({required this.textContent, super.key});

  final String textContent;

  @override
  State<CounterText> createState() => _CounterTextState();
}

class _CounterTextState extends State<CounterText> {
  late Paint _foregroundPaint;
  late Shader _maskShader1;
  late Shader _maskShader2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    const shaderRect = Rect.fromLTWH(0, 0, 400, 100);

    _foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          context.appTheme.beige100,
          const Color(0xFF86837D),
        ],
      ).createShader(shaderRect);

    _maskShader1 = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        context.appTheme.beige100,
        context.appTheme.beige100.withValues(alpha: 0),
      ],
    ).createShader(shaderRect);

    _maskShader2 = const LinearGradient(
      begin: Alignment(-2, -2),
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF703C16),
        Color(0x00703B16),
      ],
    ).createShader(shaderRect);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: FontFamily.mechsuit, fontSize: 130, height: 1.8);

    return Stack(
      children: [
        Text(
          widget.textContent,
          textAlign: TextAlign.left,
          style: textStyle.copyWith(
            foreground: _foregroundPaint,
          ),
        ),

        ShaderMask(
          shaderCallback: (bounds) => _maskShader1,
          child: Text(
            widget.textContent,
            textAlign: TextAlign.left,
            style: textStyle.copyWith(),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => _maskShader2,
          child: Text(
            widget.textContent,
            textAlign: TextAlign.left,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
