import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum WorkoutSettings {
  subscription,
  faction,
  notification,
  measureSystem,
  workoutDays,
}

extension WorkoutSettingsX on WorkoutSettings {
  String get icon {
    return switch (this) {
      WorkoutSettings.subscription => Assets.images.icons.wallet,
      WorkoutSettings.faction => Assets.images.icons.weightAlt,
      WorkoutSettings.notification => Assets.images.icons.bell,
      WorkoutSettings.measureSystem => Assets.images.icons.computing,
      WorkoutSettings.workoutDays => Assets.images.icons.calendarAlt,
    };
  }

  String title(Translations t) {
    return switch (this) {
      WorkoutSettings.subscription => 'Subscription',
      WorkoutSettings.faction => 'Change Faction',
      WorkoutSettings.notification => 'Notifications',
      WorkoutSettings.measureSystem => 'Measurement',
      WorkoutSettings.workoutDays => 'Workout days',
    };
  }
}
