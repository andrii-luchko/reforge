import 'dart:async';
import 'package:flutter/material.dart';
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

class SettingsNavigation {
  const SettingsNavigation._();

  static void open(BuildContext context, dynamic setting) {
    Widget? route;

    if (setting is ProfileSettings) {
      route = _getProfileRoute(setting);
    } else if (setting is WorkoutSettings) {
      route = _getWorkoutRoute(setting);
    }

    if (route != null) {
      unawaited(Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => route!)));
    }
  }

  static Widget? _getProfileRoute(ProfileSettings setting) {
    return switch (setting) {
      ProfileSettings.name => const NamePage(),
      ProfileSettings.email => const EmailPage(),
      ProfileSettings.dateOfBirth => const DateOfBirthPage(),
      ProfileSettings.heightAndWeight => const HeightAndWeightPage(),
      ProfileSettings.image => null,
    };
  }

  static Widget? _getWorkoutRoute(WorkoutSettings setting) {
    return switch (setting) {
      WorkoutSettings.workoutDays => const WorkoutDaysPage(),
      WorkoutSettings.faction => const ChangeFactionPage(),
      WorkoutSettings.measureSystem => const MeasurementPage(),
      WorkoutSettings.notification => const NotificationPage(),
      WorkoutSettings.subscription => const SubscriptionPage(),
    };
  }
}
