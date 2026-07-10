import 'package:freezed_annotation/freezed_annotation.dart';

part 'pose_data_point.freezed.dart';
part 'pose_data_point.g.dart';

@freezed
sealed class PoseDataPoint with _$PoseDataPoint {
  const factory PoseDataPoint({
    required int number,
    required String name,
    required double score,
    required int x,
    required int y,
  }) = _PoseDataPoint;

  factory PoseDataPoint.fromJson(Map<String, dynamic> json) => _$PoseDataPointFromJson(json);
}
