import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class AnalysisFailedDialog extends StatelessWidget {
  const AnalysisFailedDialog({
    required this.onTryAgainPressed,
    super.key,
  });

  final VoidCallback onTryAgainPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          DefaultDialogHeader(title: t.camera_detection.analysisFailedTitle),
          const SizedBox(height: 16),
          Text(
            t.camera_detection.analysisFailedDescription,
            textAlign: TextAlign.center,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: t.camera_detection.tryAgain,
            iconAsset: Assets.images.icons.upload,
            onPressed: () {
              Navigator.of(context).pop();
              onTryAgainPressed();
            },
          ),
        ],
      ),
    );
  }
}
