// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/core/user/data/models/user_subscription.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(copyWith: true, fromJson: true, toJson: true, map: FreezedMapOptions(map: true))
sealed class User with _$User {
  const factory User.newUser({required int id, String? email}) = NewUser;

  const factory User.onboarded({
    required int id,
    String? email,
    @JsonKey(name: 'bodyweight') double? bodyWeight,

    required MeasurementSystem measurementSystem,

    required int factionId,
    int? secondaryFactionId,

    required DateTime birthDate,

    required int workoutsPerWeek,
    @Default([]) List<int> specificDays,

    //just program id, not used inside the app
    int? activeProgramId,

    //important for starting workout
    int? currentProgramDayId,

    String? avatarUrl,
    @JsonKey(name: 'username') String? userName,

    @Default(false) @JsonKey(name: 'remindersEnabled') bool remindersEnabled,
    @Default(false) @JsonKey(name: 'announcementsEnabled') bool announcementsEnabled,

    @JsonKey(name: 'rank') String? rank,
    @JsonKey(name: 'japanRank') String? japanRank,
    @JsonKey(name: 'subscription') UserSubscription? subscription,
  }) = OnboardedUser;

  factory User.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json);

    if (json['trainingGoal'] != null || json['bodyweight'] != null) {
      data['runtimeType'] = 'onboarded';
    } else {
      data['runtimeType'] = 'newUser';
    }

    return _$UserFromJson(data);
  }
}

extension OnboardedUserX on OnboardedUser {
  double? get displayedWeight {
    if (bodyWeight == null) return null;
    return bodyWeight!.toDisplayWeight(measurementSystem).roundWeight();
  }

  Faction? get mainFaction {
    return Faction.fromId(factionId);
  }

  Faction? get secondaryFaction {
    return Faction.fromId(secondaryFactionId);
  }

  List<WeekDay> get specificWeekDays {
    return specificDays.map(WeekDay.fromValue).nonNulls.toList();
  }

  List<Faction> get factionsList {
    return [mainFaction, secondaryFaction].nonNulls.toList();
  }
}
