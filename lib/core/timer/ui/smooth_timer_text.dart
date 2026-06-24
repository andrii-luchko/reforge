import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SmoothTimerText extends StatefulWidget {
  const SmoothTimerText(
    this.text, {
    required this.style,
    this.digitWidth = 13.5,
    this.colonWidth = 5.0,
    super.key,
  });

  final String text;
  final TextStyle style;
  final double digitWidth;
  final double colonWidth;

  @override
  State<SmoothTimerText> createState() => _SmoothTimerTextState();
}

class _SmoothTimerTextState extends State<SmoothTimerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _oldText;

  @override
  void initState() {
    super.initState();
    _oldText = widget.text;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didUpdateWidget(SmoothTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _oldText = oldWidget.text;
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getCharWidth(String char) {
    final isColon = char == ':' || char == '.' || char == ',';
    final isSign = char == '+' || char == '-';
    if (isColon) return widget.colonWidth;
    if (isSign) return widget.digitWidth * 0.8;
    return widget.digitWidth;
  }

  double _calculateTotalWidth() {
    double width = 0;
    for (var i = 0; i < widget.text.length; i++) {
      width += _getCharWidth(widget.text[i]);
    }
    return width;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _TimerPainter(
              oldText: _oldText,
              newText: widget.text,
              progress: _controller.value,
              style: widget.style,
              digitWidth: widget.digitWidth,
              colonWidth: widget.colonWidth,
            ),
            size: Size(
              _calculateTotalWidth(),
              widget.style.fontSize ?? 20.0,
            ),
          );
        },
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.oldText,
    required this.newText,
    required this.progress,
    required this.style,
    required this.digitWidth,
    required this.colonWidth,
  });

  final String oldText;
  final String newText;
  final double progress;
  final TextStyle style;
  final double digitWidth;
  final double colonWidth;

  double _getCharWidth(String char) {
    final isColon = char == ':' || char == '.' || char == ',';
    final isSign = char == '+' || char == '-';
    if (isColon) return colonWidth;
    if (isSign) return digitWidth * 0.8;
    return digitWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var currentX = 0.0;
    final maxLength = max(oldText.length, newText.length);

    final slideDistance = size.height * 0.45;

    for (var i = 0; i < maxLength; i++) {
      final oldChar = i < oldText.length ? oldText[i] : '';
      final newChar = i < newText.length ? newText[i] : '';

      final targetChar = newChar.isNotEmpty ? newChar : oldChar;
      final charWidth = _getCharWidth(targetChar);
      final xCenter = currentX + (charWidth / 2);

      if (oldChar == newChar || progress == 1.0) {
        _drawCenteredChar(canvas, newChar, xCenter, 0, 1);
      } else {
        if (oldChar.isNotEmpty) {
          final yOffsetOld = -(progress * slideDistance);
          final opacityOld = 1.0 - progress;
          _drawCenteredChar(canvas, oldChar, xCenter, yOffsetOld, opacityOld);
        }

        if (newChar.isNotEmpty) {
          final yOffsetNew = (1.0 - progress) * slideDistance;
          final opacityNew = progress;
          _drawCenteredChar(canvas, newChar, xCenter, yOffsetNew, opacityNew);
        }
      }

      currentX += charWidth;
    }
  }

  void _drawCenteredChar(
    Canvas canvas,
    String char,
    double xCenter,
    double yOffset,
    double opacity,
  ) {
    if (opacity <= 0.01) return;

    final color = style.color ?? const Color(0xFF000000);
    final span = TextSpan(
      text: char,
      style: style.copyWith(color: color.withValues(alpha: opacity)),
    );

    final textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final x = xCenter - (textPainter.width / 2);
    final y = yOffset;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.oldText != oldText ||
        oldDelegate.newText != newText ||
        oldDelegate.style != style;
  }
}
