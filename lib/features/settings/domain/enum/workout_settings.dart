import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
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
      WorkoutSettings.subscription => t.settings.subscription,
      WorkoutSettings.faction => t.settings.changeFaction,
      WorkoutSettings.notification => t.settings.notifications,
      WorkoutSettings.measureSystem => t.settings.measurement,
      WorkoutSettings.workoutDays => t.settings.workoutDays,
    };
  }

  String? getDisplayValue(OnboardedUser user, Translations t) {
    return switch (this) {
      WorkoutSettings.subscription => null,
      WorkoutSettings.faction => '${user.mainFaction?.title(t)}, ${user.secondaryFaction?.title(t)}',
      WorkoutSettings.notification => null,
      WorkoutSettings.measureSystem => user.measurementSystem.weightSymbol(t),
      WorkoutSettings.workoutDays => t.settings.daysPerWeek(count: user.workoutsPerWeek),
    };
  }
}
