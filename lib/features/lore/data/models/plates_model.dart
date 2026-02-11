import 'package:freezed_annotation/freezed_annotation.dart';
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
