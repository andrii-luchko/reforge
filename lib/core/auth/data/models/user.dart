// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(copyWith: true, fromJson: true, toJson: true, map: FreezedMapOptions(map: true))
sealed class User with _$User {
  const factory User.newUser({
    required int id,
  }) = _NewUser;

  const factory User.onboarded({
    required int id,
    @JsonKey(name: 'bodyweight') double? bodyWeight,

    required MeasurementSystem measurementSystem,

    required int factionId,
    int? secondaryFactionId,

    required DateTime birthDate,

    required int workoutsPerWeek,
    @Default([]) List<int> specificDays,

    int? activeProgramId,
    int? currentProgramDayId,
  }) = _OnboardedUser;

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
