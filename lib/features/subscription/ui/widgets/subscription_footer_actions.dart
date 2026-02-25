import 'package:flutter/material.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

class SubscriptionFooterAction extends StatelessWidget {
  const SubscriptionFooterAction({
    required this.buttonLabel,
    required this.onPressed,
    required this.onRestorePurchases,
    super.key,
  });

  final String buttonLabel;
  final VoidCallback? onPressed;
  final VoidCallback onRestorePurchases;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryButton(
          text: buttonLabel,
          onPressed: onPressed,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThirtyButton(
              text: 'Restore Purchases',
              onPressed: onRestorePurchases,
              style: subheadH6Medium,
            ),

            ThirtyButton(
              text: 'Terms',
              onPressed: () => LaunchUrl.launchAppLink(Env.termsOfUseUrl),
              style: subheadH6Medium,
            ),

            ThirtyButton(
              text: 'Privacy',
              onPressed: () => LaunchUrl.launchAppLink(Env.privacyPolicyUrl),
              style: subheadH6Medium,
            ),
          ],
        ),
      ],
    );
  }
}
