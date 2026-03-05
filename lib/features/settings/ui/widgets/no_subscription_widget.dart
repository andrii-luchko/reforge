import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class NoSubscriptionWidget extends StatelessWidget {
  const NoSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SliverPadding(
      padding: const .only(bottom: 32, left: 16, right: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(color: appTheme.beige900, borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const .all(16),
            decoration: BoxDecoration(gradient: appTheme.cardNavigation, borderRadius: BorderRadius.circular(20)),

            child: Column(
              crossAxisAlignment: .start,

              children: [
                Text(
                  'Upgrade your subscription',
                  style: subheadH3Medium.copyWith(color: appTheme.beige100),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade your plan to unlock full access to all factions, advanced training modules, and exclusive rewards.',
                  style: subheadH5Medium.copyWith(color: appTheme.beige700),
                ),

                const SizedBox(height: 16),

                PrimaryButton(
                  text: 'See all Plans',
                  onPressed: () {
                    WorkoutSettings.subscription.push(context);
                  },
                ),
              ],
            ),
          ).animateEntrance(),
        ),
      ),
    );
  }
}
