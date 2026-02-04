import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsEditPage(
      title: WorkoutSettings.notification.title(t),
      body: const NotificationContent(),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsEditPage(
      title: WorkoutSettings.subscription.title(t),
      body: const NotificationContent(),
    );
  }
}

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  bool _reminders = false;
  bool _announcements = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        NotificationSwitcher(
          title: 'Reminders',
          value: _reminders,
          onChanged: (value) {
            setState(() {
              _reminders = value;
            });
          },
        ),
        NotificationSwitcher(
          title: 'Announcements',
          value: _announcements,
          onChanged: (value) {
            setState(() {
              _announcements = value;
            });
          },
        ),
      ],
    );
  }
}

class NotificationSwitcher extends StatelessWidget {
  const NotificationSwitcher({required this.onChanged, required this.title, required this.value, super.key});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appTheme.beige900,
        border: Border.all(color: context.appTheme.strokeCard),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const .all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: context.appTheme.cardNavigation),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              title,
              style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
            ),
            ReforgeSwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class ReforgeSwitch extends StatelessWidget {
  const ReforgeSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
        unawaited(HapticFeedback.lightImpact());
      },
      child: SizedBox(
        width: 36,
        height: 20,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC66C32),
                    Color(0x00C66C32),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),

                  color: value ? const Color(0xFF9D3C10) : const Color(0xFF4B2105),
                ),
              ),
            ),

            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDDD7CD),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF101828).withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                      BoxShadow(
                        color: const Color(0xFF101828).withValues(alpha: 0.06),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
