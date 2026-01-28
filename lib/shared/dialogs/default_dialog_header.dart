import 'package:flutter/material.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class DefaultDialogHeader extends StatelessWidget {
  const DefaultDialogHeader({required this.title, this.onClosePressed, this.textFlex = 4, super.key});

  final String title;
  final VoidCallback? onClosePressed;
  final int textFlex;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        const Spacer(),
        Expanded(
          flex: textFlex,
          child: Text(
            title,
            style: subheadH2Medium,
            textAlign: TextAlign.center,
          ),
        ),
        AppIconButton.icon(
          iconData: Icons.close,
          onPressed: onClosePressed ?? () => Navigator.pop(context),
        ),
      ],
    );
  }
}
