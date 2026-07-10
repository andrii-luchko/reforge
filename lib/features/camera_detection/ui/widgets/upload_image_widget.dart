import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
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
          text: 'Upload image',
          assetPath: Assets.images.icons.upload,
          themeColor: appTheme.beige100,
        ),
        Text(
          'Upload a clear full-body photo to get accurate posture results',
          textAlign: .center,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
      ],
    );
  }
}
