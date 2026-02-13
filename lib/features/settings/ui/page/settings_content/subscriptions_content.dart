import 'package:flutter/widgets.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsEditPage(
      title: WorkoutSettings.subscription.title(t),
      body: const SubscriptionsContent(),
    );
  }
}

class SubscriptionsContent extends StatelessWidget {
  const SubscriptionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column();
  }
}
