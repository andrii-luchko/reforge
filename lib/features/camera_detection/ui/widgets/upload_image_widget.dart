import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/text_button.dart';

class UploadImageWidget extends StatelessWidget {
  const UploadImageWidget({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      spacing: 8,
      mainAxisAlignment: .center,
      children: [
        AppTextButton(
          onPressed: onPressed,
          padding: const .only(bottom: 8),
          decoration: BoxDecoration(
            border: .fromLTRB(bottom: BorderSide(color: appTheme.beige100)),
          ),
          text: t.camera_detection.uploadImage,
          assetPath: Assets.images.icons.upload,
          themeColor: appTheme.beige100,
        ),
        Text(
          t.camera_detection.uploadImageDescription,
          textAlign: .center,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
      ],
    );
  }
}
