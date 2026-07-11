import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum PoseDetectionPreset {
  spine,
  legs,
}

extension PoseDetectionPresetX on PoseDetectionPreset {
  String label(Translations t) {
    return switch (this) {
      PoseDetectionPreset.spine => t.camera_detection.presets.spine,
      PoseDetectionPreset.legs => t.camera_detection.presets.legs,
    };
  }

  String get iconAsset {
    return switch (this) {
      PoseDetectionPreset.spine => Assets.images.icons.leftShoulder,
      PoseDetectionPreset.legs => Assets.images.icons.leftLeg,
    };
  }
}
