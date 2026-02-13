import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/lore/data/models/jiku_plate_dto.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

part 'plates_model.freezed.dart';
part 'plates_model.g.dart';

@freezed
sealed class PlatesModel with _$PlatesModel {
  const PlatesModel._();

  const factory PlatesModel({
    required int id,
    required String name,
    required String title,
    required String? imageUrl,
    required String? loreBody,
    required int unlockLevel,
    required bool isLocked,
  }) = _PlatesModel;

  factory PlatesModel.fromJson(Map<String, dynamic> json) => _$PlatesModelFromJson(json);

  factory PlatesModel.fromListDto(JikuPlateListDto dto) => PlatesModel(
        id: dto.id,
        name: dto.title,
        title: dto.title,
        imageUrl: dto.imageUrl,
        loreBody: null,
        unlockLevel: dto.unlockLevel,
        isLocked: !dto.isUnlocked,
      );

  factory PlatesModel.fromDetailDto(JikuPlateDetailDto dto) => PlatesModel(
        id: dto.id,
        name: dto.title,
        title: dto.title,
        imageUrl: dto.imageUrl,
        loreBody: dto.text,
        unlockLevel: dto.unlockLevel,
        isLocked: false,
      );

  PlatesModel mergeWithDetail(PlatesModel detail) => copyWith(
        loreBody: detail.loreBody,
        imageUrl: detail.imageUrl,
        title: detail.title,
        name: detail.name,
      );

  PlatesEntity toEntity() {
    return PlatesEntity(
      id: id,
      name: name,
      title: title,
      imageUrl: imageUrl,
      loreBody: loreBody,
      unlockLevel: unlockLevel,
      isLocked: isLocked,
    );
  }

  // ignore: sort_constructors_first
  factory PlatesModel.fromEntity(PlatesEntity entity) => PlatesModel(
    id: entity.id,
    name: entity.name,
    title: entity.title,
    imageUrl: entity.imageUrl,
    loreBody: entity.loreBody,
    unlockLevel: entity.unlockLevel,
    isLocked: entity.isLocked,
  );
}
