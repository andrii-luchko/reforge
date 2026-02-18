import 'package:flutter/material.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionManageButton extends StatelessWidget {
  const SubscriptionManageButton({
    this.managementUrl,
    super.key,
  });

  final String? managementUrl;

  Future<void> _openManagementUrl(BuildContext context) async {
    final url = managementUrl;
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      text: t.subscription.manageSubscription,
      onPressed: managementUrl != null ? () => _openManagementUrl(context) : null,
    );
  }
}
