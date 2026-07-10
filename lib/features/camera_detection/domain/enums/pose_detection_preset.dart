import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum PoseDetectionPreset {
  spine,
  legs,
}

extension PoseDetectionPresetX on PoseDetectionPreset {
  String get label {
    return switch (this) {
      PoseDetectionPreset.spine => 'Spine',
      PoseDetectionPreset.legs => 'Legs',
    };
  }

  String get iconAsset {
    return switch (this) {
      PoseDetectionPreset.spine => Assets.images.icons.leftShoulder,
      PoseDetectionPreset.legs => Assets.images.icons.leftLeg,
    };
  }
}
