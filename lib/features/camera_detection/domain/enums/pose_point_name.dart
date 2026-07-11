import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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
  String label(Translations t) {
    return switch (this) {
      PosePointName.head => t.camera_detection.posePoints.head,
      PosePointName.leftShoulder => t.camera_detection.posePoints.leftShoulder,
      PosePointName.rightShoulder => t.camera_detection.posePoints.rightShoulder,
      PosePointName.leftPelvis => t.camera_detection.posePoints.leftPelvis,
      PosePointName.rightPelvis => t.camera_detection.posePoints.rightPelvis,
      PosePointName.leftKnee => t.camera_detection.posePoints.leftKnee,
      PosePointName.rightKnee => t.camera_detection.posePoints.rightKnee,
      PosePointName.leftFoot => t.camera_detection.posePoints.leftFoot,
      PosePointName.rightFoot => t.camera_detection.posePoints.rightFoot,
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
