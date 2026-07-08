import 'package:flutter/material.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StartWorkoutButton extends StatelessWidget {
  const StartWorkoutButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.5 - 32;
    return Skeleton.leaf(
      child: Container(
        color: Colors.transparent,
        padding: const .symmetric(vertical: 16),
        width: buttonWidth,
        child: PrimaryButton(
          text: t.workout_details.startWorkout,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
