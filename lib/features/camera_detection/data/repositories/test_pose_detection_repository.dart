import 'dart:io';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/pose_detection_repository.dart';

class TestPoseDetectionRepository with RepositoryErrorHandler implements PoseDetectionRepository {
  const TestPoseDetectionRepository();

  @override
  Future<Result<List<PoseDataPoint>>> analyze(File image) async {
    try {
      final points = await makeRequest(
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 350));

          return _testPoints.map(PoseDataPoint.fromJson).toList();
        },
        label: 'poseDetectionAnalyze',
      );

      return Result.success(points);
    } on Exception catch (e, stackTrace) {
      return Result.error(e, stackTrace);
    }
  }
}

const List<Map<String, Object>> _testPoints = [
  {
    'number': 1,
    'name': 'head',
    'score': 0.9999999012070495,
    'x': 167,
    'y': 165,
  },
  {
    'number': 2,
    'name': 'left_shoulder',
    'score': 0.9999734031923209,
    'x': 147,
    'y': 186,
  },
  {
    'number': 3,
    'name': 'right_shoulder',
    'score': 0.9999975655283914,
    'x': 89,
    'y': 154,
  },
  {
    'number': 4,
    'name': 'left_pelvis',
    'score': 0.9998051262946942,
    'x': 90,
    'y': 243,
  },
  {
    'number': 5,
    'name': 'right_pelvis',
    'score': 0.9999778484680368,
    'x': 49,
    'y': 240,
  },
  {
    'number': 6,
    'name': 'left_knee',
    'score': 0.9623375838253436,
    'x': 163,
    'y': 255,
  },
  {
    'number': 7,
    'name': 'right_knee',
    'score': 0.9882322650639749,
    'x': 60,
    'y': 255,
  },
  {
    'number': 8,
    'name': 'left_foot',
    'score': 0.8936409817556623,
    'x': 256,
    'y': 228,
  },
  {
    'number': 9,
    'name': 'right_foot',
    'score': 0.4685306729820031,
    'x': 127,
    'y': 262,
  },
];
