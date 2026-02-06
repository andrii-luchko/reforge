// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:reforge/generated/flutter_gen/fonts.gen.dart';

class GradientTextHeader extends StatelessWidget {
  const GradientTextHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        GradientText(
          text: 'IMMORTAL',
        ),
        GradientText(
          text: 'FORGES',
        ),
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText({
    required this.text,
    super.key,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFECE7DC), Color(0x00ECE7DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: FontFamily.mechsuit,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
