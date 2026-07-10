import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';

part 'camera_detection_cubit.freezed.dart';

@freezed
sealed class CameraDetectionState with _$CameraDetectionState {
  const CameraDetectionState._();
  const factory CameraDetectionState({
    String? imagePath,
    @Default([]) List<PoseDataPoint> detectedDots,
    @Default(false) bool isLoading,
    String? error,
  }) = _CalendarState;
}

@injectable
class CameraDetectionCubit extends Cubit<CameraDetectionState> {
  CameraDetectionCubit() : super(const CameraDetectionState());
}
