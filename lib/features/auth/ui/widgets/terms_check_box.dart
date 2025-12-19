import 'package:flutter/material.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_check_box.dart';

class TermsConfirmationCheckBox extends StatelessWidget {
  const TermsConfirmationCheckBox({
    required this.onChanged,
    required this.value,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const .only(top: 16),
      child: Row(
        children: [
          AppCheckbox(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              text: t.create_acc.terms_text_part1,
              style: subheadH8Semibold.copyWith(color: appTheme.beige700),
              children: [
                TextSpan(
                  recognizer: launchUrlRecognizer(Env.termsOfUseUrl),
                  text: t.create_acc.terms_text_part2,
                  style: subheadH8Semibold.copyWith(color: appTheme.beige100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
