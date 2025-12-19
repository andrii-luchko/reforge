import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.size = 20.0,
    this.borderRadius = 2.0,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.beige1000,

          border: Border.all(
            color: theme.beige700,
            width: 2,
          ),

          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SvgPicture.asset(Assets.images.icons.check),
          ),
        ),
      ),
    );
  }
}
