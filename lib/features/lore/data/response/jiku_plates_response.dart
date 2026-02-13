import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/features/lore/data/models/jiku_plate_dto.dart';

part 'jiku_plates_response.freezed.dart';
part 'jiku_plates_response.g.dart';

@freezed
sealed class JikuPlatesResponse with _$JikuPlatesResponse {
  const factory JikuPlatesResponse({
    required List<JikuPlateListDto> data,
    required MetaData meta,
    required String status,
  }) = _JikuPlatesResponse;

  factory JikuPlatesResponse.fromJson(Map<String, dynamic> json) =>
      _$JikuPlatesResponseFromJson(json);
}
