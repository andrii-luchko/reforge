import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/photo/service/image_compress_service.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/pose_detection_repository.dart';

@Injectable(as: PoseDetectionRepository)
class PoseDetectionRepoImpl with RepositoryErrorHandler implements PoseDetectionRepository {
  const PoseDetectionRepoImpl(this._apiClient, this._service);

  final ApiClient _apiClient;
  final ImageService _service;

  @override
  Future<Result<List<PoseDataPoint>>> analyze(File image) async {
    try {
      final result = await _service.checkSizeAndCompressIfNeeded(image);

      switch (result) {
        case Success(value: final file):
          final result = await makeRequest(
            () => _apiClient.detectPose(file: file),
            label: 'poseDetectionAnalyze',
          );
          final points = result.data;

          if (points.isEmpty) {
            return const Result.error(LowConfidencePoseException());
          }

          final isLowScoredAnalyze = points.every((p) => p.isLowConfidence);

          if (isLowScoredAnalyze) {
            return const Result.error(LowConfidencePoseException());
          }

          return Result.success(points);

        case Failure(error: final e):
          return Result.error(e);
      }
    } on Exception catch (e, stackTrace) {
      return Result.error(e, stackTrace);
    }
  }
}

class LowConfidencePoseException implements Exception {
  const LowConfidencePoseException([this.message = 'Could not recognize the body clearly.']);
  final String message;

  @override
  String toString() => message;
}
