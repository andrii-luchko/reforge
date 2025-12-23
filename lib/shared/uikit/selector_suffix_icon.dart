import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

class SelectorSuffixIcon extends StatelessWidget {
  const SelectorSuffixIcon({
    required this.isOpen,
    super.key,
  });

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: context.appTheme.beige100,
      ),
    );
  }
}
