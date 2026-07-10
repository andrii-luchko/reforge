import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/camera_detection/data/models/pose_data_point.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/camera_detection/domain/pose_angle_calculator.dart';
import 'package:reforge/features/camera_detection/domain/pose_detection_repository.dart';

part 'camera_detection_cubit.freezed.dart';

@freezed
sealed class CameraDetectionState with _$CameraDetectionState {
  const CameraDetectionState._();

  const factory CameraDetectionState.initial({
    int? selectedSetId,
  }) = CameraDetectionInitial;

  const factory CameraDetectionState.imageSelected({
    required String imagePath,
    required Size originalImageSize,
    int? selectedSetId,
  }) = CameraDetectionImageSelected;

  const factory CameraDetectionState.analyzing({
    required String imagePath,
    required Size originalImageSize,
    required PoseDetectionPreset preset,
    int? selectedSetId,
  }) = CameraDetectionAnalyzing;

  const factory CameraDetectionState.adjusting({
    required String imagePath,
    required Size originalImageSize,
    required PoseDetectionPreset preset,
    required List<PoseDataPoint> originalPoints,
    required List<PoseDataPoint> points,
    PoseAngleResult? angleResult,
    int? selectedSetId,
    String? error,
  }) = CameraDetectionAdjusting;

  const factory CameraDetectionState.savingResult({
    required String imagePath,
    required Size originalImageSize,
    required PoseDetectionPreset preset,
    required List<PoseDataPoint> originalPoints,
    required List<PoseDataPoint> points,
    required PoseAngleResult angleResult,
    required int selectedSetId,
  }) = CameraDetectionSavingResult;

  @override
  int? get selectedSetId {
    return switch (this) {
      CameraDetectionInitial(:final selectedSetId) => selectedSetId,
      CameraDetectionImageSelected(:final selectedSetId) => selectedSetId,
      CameraDetectionAnalyzing(:final selectedSetId) => selectedSetId,
      CameraDetectionAdjusting(:final selectedSetId) => selectedSetId,
      CameraDetectionSavingResult(:final selectedSetId) => selectedSetId,
    };
  }

  bool get hasImage {
    return switch (this) {
      CameraDetectionInitial() => false,
      CameraDetectionImageSelected() ||
      CameraDetectionAnalyzing() ||
      CameraDetectionAdjusting() ||
      CameraDetectionSavingResult() => true,
    };
  }

  bool get canAnalyze => this is CameraDetectionImageSelected;

  bool get canConfirm {
    final current = this;
    return current is CameraDetectionAdjusting && current.selectedSetId != null && current.angleResult != null;
  }
}

@injectable
class CameraDetectionCubit extends Cubit<CameraDetectionState> {
  CameraDetectionCubit(this._repository) : super(const CameraDetectionState.initial());

  final PoseDetectionRepository _repository;
  final PoseAngleCalculator _angleCalculator = const PoseAngleCalculator();

  Future<void> setImage(File file) async {
    final imageSize = await _readImageSize(file);
    if (isClosed) return;

    emit(
      CameraDetectionState.imageSelected(
        imagePath: file.path,
        originalImageSize: imageSize,
        selectedSetId: state.selectedSetId,
      ),
    );
  }

  Future<void> analyzeImage({required PoseDetectionPreset preset}) async {
    final current = state;
    if (current is! CameraDetectionImageSelected) return;

    emit(
      CameraDetectionState.analyzing(
        imagePath: current.imagePath,
        originalImageSize: current.originalImageSize,
        preset: preset,
        selectedSetId: current.selectedSetId,
      ),
    );

    final result = await _repository.analyze(File(current.imagePath));
    if (isClosed) return;

    switch (result) {
      case Success(:final value):
        final angleResult = _angleCalculator.calculate(
          preset: preset,
          points: value,
        );

        emit(
          CameraDetectionState.adjusting(
            imagePath: current.imagePath,
            originalImageSize: current.originalImageSize,
            preset: preset,
            originalPoints: value,
            points: value,
            angleResult: angleResult,
            selectedSetId: current.selectedSetId,
            error: angleResult == null ? 'Cannot calculate pose angle' : null,
          ),
        );

      case Failure(:final error):
        emit(
          CameraDetectionState.adjusting(
            imagePath: current.imagePath,
            originalImageSize: current.originalImageSize,
            preset: preset,
            originalPoints: const [],
            points: const [],
            selectedSetId: current.selectedSetId,
            error: error.toString(),
          ),
        );
    }
  }

  void selectSet(int? setId) {
    final current = state;

    emit(
      switch (current) {
        CameraDetectionInitial() => current.copyWith(selectedSetId: setId),
        CameraDetectionImageSelected() => current.copyWith(selectedSetId: setId),
        CameraDetectionAnalyzing() => current.copyWith(selectedSetId: setId),
        CameraDetectionAdjusting() => current.copyWith(selectedSetId: setId, error: null),
        CameraDetectionSavingResult() => current.copyWith(selectedSetId: setId ?? current.selectedSetId),
      },
    );
  }

  void movePoint({
    required int pointNumber,
    required Offset position,
  }) {
    movePoints({pointNumber: position});
  }

  void movePoints(Map<int, Offset> updates) {
    final current = state;
    if (current is! CameraDetectionAdjusting || updates.isEmpty) return;

    final updatedPoints = current.points.map((point) {
      final position = updates[point.number];
      if (position == null) return point;

      return point.copyWith(
        x: position.dx.round(),
        y: position.dy.round(),
      );
    }).toList();

    emit(
      current.copyWith(
        points: updatedPoints,
        angleResult: _angleCalculator.calculate(
          preset: current.preset,
          points: updatedPoints,
        ),
        error: null,
      ),
    );
  }

  void resetPoints() {
    final current = state;
    if (current is! CameraDetectionAdjusting) return;

    emit(
      current.copyWith(
        points: current.originalPoints,
        angleResult: _angleCalculator.calculate(
          preset: current.preset,
          points: current.originalPoints,
        ),
        error: null,
      ),
    );
  }

  double? startSavingResult() {
    final current = state;
    if (current is! CameraDetectionAdjusting) return null;

    final selectedSetId = current.selectedSetId;
    final angleResult = current.angleResult;
    if (selectedSetId == null) {
      emit(current.copyWith(error: 'Select set first'));
      return null;
    }

    if (angleResult == null) {
      emit(current.copyWith(error: 'Cannot calculate pose angle'));
      return null;
    }

    emit(
      CameraDetectionState.savingResult(
        imagePath: current.imagePath,
        originalImageSize: current.originalImageSize,
        preset: current.preset,
        originalPoints: current.originalPoints,
        points: current.points,
        angleResult: angleResult,
        selectedSetId: selectedSetId,
      ),
    );

    return angleResult.angle;
  }

  void reset() {
    emit(const CameraDetectionState.initial());
  }

  Future<Size> _readImageSize(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());

    image.dispose();
    codec.dispose();

    return size;
  }
}
