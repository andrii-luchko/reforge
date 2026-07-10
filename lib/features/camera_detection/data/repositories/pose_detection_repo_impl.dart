import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/pose_detection_repository.dart';

@Injectable(as: PoseDetectionRepository)
class PoseDetectionRepoImpl with RepositoryErrorHandler implements PoseDetectionRepository {
  const PoseDetectionRepoImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<List<PoseDataPoint>>> analyze(File image) async {
    try {
      final points = await makeRequest(
        () async {
          return _apiClient.detectPose(file: image);
        },
        label: 'poseDetectionAnalyze',
      );

      return Result.success(points.data);
    } on Exception catch (e, stackTrace) {
      return Result.error(e, stackTrace);
    }
  }
}
