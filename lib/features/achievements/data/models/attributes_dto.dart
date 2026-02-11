import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';

part 'attributes_dto.freezed.dart';
part 'attributes_dto.g.dart';

@freezed
sealed class AttributesDto with _$AttributesDto {
  const factory AttributesDto({
    required String id,
    required String name,
    required int currentXp,
    required int totalXp,
  }) = _AttributesDto;

  const AttributesDto._();

  factory AttributesDto.fromJson(Map<String, dynamic> json) => _$AttributesDtoFromJson(json);

  AttributesEntity toDomain() {
    return AttributesEntity(
      attribute: ForgeAttribute.values.firstWhere(
        (e) => e.name == id,
        orElse: () => ForgeAttribute.kobo,
      ),
      currentXp: currentXp,
      totalXp: totalXp,
    );
  }
}
