// ignore_for_file: one_member_abstracts

import 'dart:io';

import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';

abstract interface class PoseDetectionRepository {
  Future<Result<List<PoseDataPoint>>> analyze(File image);
}
