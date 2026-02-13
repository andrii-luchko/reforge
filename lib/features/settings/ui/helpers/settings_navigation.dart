import 'dart:async';
import 'package:flutter/material.dart';
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
import 'package:reforge/features/settings/ui/page/settings_content/subscriptions_content.dart';
import 'package:reforge/features/settings/ui/page/settings_content/workout_days_content.dart';

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
      unawaited(Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => route!)));
    }
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
      //TODO (Masayoshi) continue setup when ready
      WorkoutSettings.notification => const SettingsNotificationPage(),
      WorkoutSettings.subscription => const SubscriptionPage(),
    };
  }
}
