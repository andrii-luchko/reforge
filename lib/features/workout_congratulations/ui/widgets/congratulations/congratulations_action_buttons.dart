import 'package:flutter/material.dart';
import 'package:reforge/features/workout_share/ui/widgets/share/share_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class CongratulationsActionButtons extends StatelessWidget {
  const CongratulationsActionButtons({
    required this.shareContent,
    required this.onNextPressed,
    this.nextButtonText,
    super.key,
  });

  final Widget shareContent;
  final VoidCallback onNextPressed;
  final String? nextButtonText;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: ShareButton(shareContent: shareContent),
        ),
        Expanded(
          child: PrimaryButton(
            text: nextButtonText ?? t.common.next_button,
            onPressed: onNextPressed,
          ),
        ),
      ],
    );
  }
}
