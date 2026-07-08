import 'package:flutter/material.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class TwoOptionsDialog extends StatefulWidget {
  const TwoOptionsDialog({
    required this.title,
    required this.rightButtonLabel,
    required this.leftButtonLabel,

    required this.contentBuilder,
    this.buttonSpacing = 16,
    this.onLeftOptionPressed,
    this.onRightOptionPressed,
    super.key,
  });

  final String title;
  final String leftButtonLabel;
  final String rightButtonLabel;
  final VoidCallback? onRightOptionPressed;
  final VoidCallback? onLeftOptionPressed;

  final double buttonSpacing;

  final Widget Function(BuildContext context) contentBuilder;

  @override
  State<TwoOptionsDialog> createState() => _TwoOptionsDialogState();
}

class _TwoOptionsDialogState extends State<TwoOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        spacing: 32,
        children: [
          DefaultDialogHeader(title: widget.title),

          widget.contentBuilder(context),

          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: widget.leftButtonLabel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    widget.onLeftOptionPressed?.call();
                  },
                ),
              ),
              SizedBox(width: widget.buttonSpacing),
              Expanded(
                child: PrimaryButton(
                  text: widget.rightButtonLabel,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    widget.onRightOptionPressed?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
