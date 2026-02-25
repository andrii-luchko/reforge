import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';

class SettingsNavigation {
  const SettingsNavigation._();

  /// Returns the analytics event for the given setting (used by route builds).
  static String? eventFor(dynamic setting) {
    if (setting is ProfileSettings) {
      return switch (setting) {
        ProfileSettings.name => AnalyticsEvents.settingsNameView,
        ProfileSettings.email => AnalyticsEvents.settingsEmailView,
        ProfileSettings.dateOfBirth => AnalyticsEvents.settingsDateOfBirthView,
        ProfileSettings.heightAndWeight => AnalyticsEvents.settingsHeightAndWeightView,
        ProfileSettings.image => null,
      };
    }
    if (setting is WorkoutSettings) {
      return switch (setting) {
        WorkoutSettings.workoutDays => AnalyticsEvents.settingsWorkoutDaysView,
        WorkoutSettings.faction => AnalyticsEvents.settingsFactionView,
        WorkoutSettings.measureSystem => AnalyticsEvents.settingsMeasurementView,
        WorkoutSettings.notification => AnalyticsEvents.settingsNotificationsView,
        WorkoutSettings.subscription => AnalyticsEvents.settingsSubscriptionView,
        WorkoutSettings.privacy => AnalyticsEvents.settingsPrivacyView,
        WorkoutSettings.termsAndConditions => AnalyticsEvents.settingsTermsAndConditionsView,
      };
    }
    return null;
  }
}

/// Wraps a settings sub-screen and logs the given analytics event once on build.
class SettingsScreenWithAnalytics extends StatefulWidget {
  const SettingsScreenWithAnalytics({
    required this.event,
    required this.child,
    super.key,
  });

  final String? event;
  final Widget child;

  @override
  State<SettingsScreenWithAnalytics> createState() => _SettingsScreenWithAnalyticsState();
}

class _SettingsScreenWithAnalyticsState extends State<SettingsScreenWithAnalytics> {
  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      unawaited(di.getIt<AnalyticsService>().logEvent(event));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
