// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';

part 'jiku_plate_dto.freezed.dart';
part 'jiku_plate_dto.g.dart';

@freezed
sealed class JikuPlateListDto with _$JikuPlateListDto {
  const factory JikuPlateListDto({
    required int id,
    String? imageUrl,
    required String title,
    required int unlockLevel,
    @JsonKey(name: 'isUnlocked') required bool isUnlocked,
  }) = _JikuPlateListDto;

  factory JikuPlateListDto.fromJson(Map<String, dynamic> json) => _$JikuPlateListDtoFromJson(json);
}

@freezed
sealed class JikuPlateDetailDto with _$JikuPlateDetailDto {
  const factory JikuPlateDetailDto({
    required int id,
    String? imageUrl,
    required String title,
    String? text,
    required int unlockLevel,
  }) = _JikuPlateDetailDto;

  factory JikuPlateDetailDto.fromJson(Map<String, dynamic> json) => _$JikuPlateDetailDtoFromJson(json);
}
