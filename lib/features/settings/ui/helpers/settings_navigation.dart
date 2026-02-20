import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/settings_content/change_faction_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/date_of_birth_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/email_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/height_and_weight_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/measurement_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/name_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/notification_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/workout_days_content.dart';
import 'package:reforge/features/subscription/ui/pages/subscription_page.dart';

class SettingsNavigation {
  const SettingsNavigation._();

  static void open(BuildContext context, dynamic setting, OnboardedUser user) {
    Widget? route;

    if (setting is ProfileSettings) {
      route = _getProfileRoute(setting, user);
    } else if (setting is WorkoutSettings) {
      route = _getWorkoutRoute(setting, user);
    }

    if (route != null) {
      final event = _getViewEvent(setting);
      final wrappedRoute = _SettingsScreenWithAnalytics(
        event: event,
        child: route,
      );
      unawaited(Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => wrappedRoute)));
    }
  }

  static String? _getViewEvent(dynamic setting) {
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

  static Widget? _getProfileRoute(ProfileSettings setting, OnboardedUser user) {
    return switch (setting) {
      ProfileSettings.name => NamePage(
        name: user.userName,
      ),
      ProfileSettings.email => EmailPage(
        initialEmail: user.email,
      ),
      ProfileSettings.dateOfBirth => DateOfBirthPage(
        dateOfBirth: user.birthDate,
      ),
      ProfileSettings.heightAndWeight => HeightAndWeightPage(
        weight: user.displayedWeight,
        system: user.measurementSystem,
      ),
      ProfileSettings.image => null,
    };
  }

  static Widget? _getWorkoutRoute(WorkoutSettings setting, OnboardedUser user) {
    return switch (setting) {
      WorkoutSettings.workoutDays => WorkoutDaysPage(
        workoutsPerWeek: user.workoutsPerWeek,
        specificWeekDays: user.specificWeekDays,
      ),
      WorkoutSettings.faction => ChangeFactionPage(
        initialFactions: user.factionsList,
      ),
      WorkoutSettings.measureSystem => MeasurementPage(
        system: user.measurementSystem,
      ),
      WorkoutSettings.notification => const SettingsNotificationPage(),
      WorkoutSettings.subscription => const SubscriptionPage(),
      WorkoutSettings.privacy => null,
      WorkoutSettings.termsAndConditions => null,
    };
  }
}

class _SettingsScreenWithAnalytics extends StatefulWidget {
  const _SettingsScreenWithAnalytics({
    required this.event,
    required this.child,
  });

  final String? event;
  final Widget child;

  @override
  State<_SettingsScreenWithAnalytics> createState() => _SettingsScreenWithAnalyticsState();
}

class _SettingsScreenWithAnalyticsState extends State<_SettingsScreenWithAnalytics> {
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
