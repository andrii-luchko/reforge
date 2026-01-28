import 'package:flutter/material.dart';

class SmoothTimerText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final characters = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,

      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: characters.map((char) {
        final isColon = char == ':' || char == '.' || char == ',';

        final isSign = char == '+' || char == '-';

        var width = digitWidth;
        if (isColon) width = colonWidth;
        if (isSign) width = digitWidth * 0.8;

        return SizedBox(
          width: width,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.45),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              char,
              key: ValueKey(char),
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
