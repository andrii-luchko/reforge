import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum PosePointName {
  head,
  leftShoulder,
  rightShoulder,
  leftPelvis,
  rightPelvis,
  leftKnee,
  rightKnee,
  leftFoot,
  rightFoot,
}

extension PosePointNameX on PosePointName {
  String get label {
    return switch (this) {
      PosePointName.head => 'Head',
      PosePointName.leftShoulder => 'Left shoulder',
      PosePointName.rightShoulder => 'Right shoulder',
      PosePointName.leftPelvis => 'Left pelvis',
      PosePointName.rightPelvis => 'Right pelvis',
      PosePointName.leftKnee => 'Left knee',
      PosePointName.rightKnee => 'Right knee',
      PosePointName.leftFoot => 'Left foot',
      PosePointName.rightFoot => 'Right foot',
    };
  }

  String get iconAsset {
    return switch (this) {
      PosePointName.head => Assets.images.icons.head,
      PosePointName.leftShoulder => Assets.images.icons.leftShoulder,
      PosePointName.rightShoulder => Assets.images.icons.rightShoulder,
      PosePointName.leftPelvis => Assets.images.icons.leftPelvis,
      PosePointName.rightPelvis => Assets.images.icons.rightPelvis,
      PosePointName.leftKnee => Assets.images.icons.leftLeg,
      PosePointName.rightKnee => Assets.images.icons.rightLeg,
      PosePointName.leftFoot => Assets.images.icons.leftFoot,
      PosePointName.rightFoot => Assets.images.icons.rightFoot,
    };
  }
}
