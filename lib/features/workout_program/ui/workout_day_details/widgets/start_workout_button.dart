import 'package:flutter/material.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StartWorkoutButton extends StatefulWidget {
  const StartWorkoutButton({
    required this.onPressed,
    super.key,
  });

  final Future<void> Function()? onPressed;

  @override
  State<StartWorkoutButton> createState() => _StartWorkoutButtonState();
}

class _StartWorkoutButtonState extends State<StartWorkoutButton> {
  var _isProcessing = false;

  Future<void> _handlePressed() async {
    final callback = widget.onPressed;
    if (_isProcessing || callback == null) return;
    setState(() => _isProcessing = true);
    try {
      await callback();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.5 - 32;
    return Skeleton.leaf(
      child: Container(
        color: Colors.transparent,
        padding: const .symmetric(vertical: 16),
        width: buttonWidth,
        child: Semantics(
          button: true,
          label: t.workout_details.startWorkout,
          child: PrimaryButton(
            text: t.workout_details.startWorkout,
            onPressed: _isProcessing || widget.onPressed == null ? null : _handlePressed,
          ),
        ),
      ),
    );
  }
}
