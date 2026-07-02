import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SmoothTimerText extends StatefulWidget {
  const SmoothTimerText(
    this.text, {
    required this.style,
    super.key,
  });

  final String text;
  final TextStyle style;

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

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);
    final tabularStyle = baseStyle.merge(
      const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
    );

    final textScaler = MediaQuery.textScalerOf(context);

    final digitPainter = TextPainter(
      text: TextSpan(text: '0', style: tabularStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();

    final colonPainter = TextPainter(
      text: TextSpan(text: ':', style: tabularStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();

    double calculateTotalWidth() {
      double width = 0;
      for (var i = 0; i < widget.text.length; i++) {
        final char = widget.text[i];
        width += (char == ':' || char == '.' || char == ',') ? colonPainter.width : digitPainter.width;
      }
      return width;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OptimizedTimerPainter(
              oldText: _oldText,
              newText: widget.text,
              progress: _controller.value,
              style: tabularStyle,
              digitWidth: digitPainter.width,
              colonWidth: colonPainter.width,
            ),
            size: Size(calculateTotalWidth(), digitPainter.height),
          );
        },
      ),
    );
  }
}

class _OptimizedTimerPainter extends CustomPainter {
  _OptimizedTimerPainter({
    required this.oldText,
    required this.newText,
    required this.progress,
    required this.style,
    required this.digitWidth,
    required this.colonWidth,
  }) {
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
  }

  final String oldText;
  final String newText;
  final double progress;
  final TextStyle style;
  final double digitWidth;
  final double colonWidth;

  late final TextPainter _textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    var currentX = 0.0;
    final maxLength = max(oldText.length, newText.length);
    final slideDistance = size.height * 0.45;

    for (var i = 0; i < maxLength; i++) {
      final oldChar = i < oldText.length ? oldText[i] : '';
      final newChar = i < newText.length ? newText[i] : '';

      final isColon = newChar == ':' || oldChar == ':';
      final charWidth = isColon ? colonWidth : digitWidth;
      final xCenter = currentX + (charWidth / 2);

      if (oldChar == newChar || progress == 1.0) {
        _drawChar(canvas, newChar, xCenter, 0, 1);
      } else {
        if (oldChar.isNotEmpty) {
          _drawChar(canvas, oldChar, xCenter, -(progress * slideDistance), 1.0 - progress);
        }
        if (newChar.isNotEmpty) {
          _drawChar(canvas, newChar, xCenter, (1.0 - progress) * slideDistance, progress);
        }
      }
      currentX += charWidth;
    }
  }

  void _drawChar(Canvas canvas, String char, double xCenter, double yOffset, double opacity) {
    if (opacity <= 0.01 || char.isEmpty) return;

    final color = style.color ?? const Color(0xFF000000);
    _textPainter.text = TextSpan(
      text: char,
      style: style.copyWith(color: color.withValues(alpha: opacity)),
    );

    _textPainter.layout();
    final x = xCenter - (_textPainter.width / 2);
    _textPainter.paint(canvas, Offset(x, yOffset));
  }

  @override
  bool shouldRepaint(covariant _OptimizedTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.oldText != oldText ||
        oldDelegate.newText != newText ||
        oldDelegate.style != style;
  }
}
