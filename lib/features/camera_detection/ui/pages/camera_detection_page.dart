import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/core/photo/service/image_picker_service.dart';
import 'package:reforge/core/photo/ui/image_source_picker_dialog.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/camera_detection/ui/widgets/analysis_failed_dialog.dart';
import 'package:reforge/features/camera_detection/ui/widgets/analyze_image_dialog.dart';
import 'package:reforge/features/camera_detection/ui/widgets/camera_detection_image_section.dart';
import 'package:reforge/features/camera_detection/ui/widgets/set_selection_field.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/workout_program/ui/exercise_instruction/widgets/video_section.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_section.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:toastification/toastification.dart';

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({super.key});

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  final TextEditingController _setTextField = TextEditingController();
  final ValueNotifier<bool> _isDraggingPosePoint = ValueNotifier(false);
  bool _isAnalyzeDialogOpen = false;
  bool _isRetryDialogOpen = false;

  @override
  void dispose() {
    _setTextField.dispose();
    _isDraggingPosePoint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraDetectionCubit, CameraDetectionState>(
      listener: _onCameraDetectionStateChanged,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
          builder: (context, exerciseState) {
            final activeExerciseCubit = context.read<ActiveExerciseCubit>();
            final programExercise = activeExerciseCubit.programExercise;
            final exerciseDetails = programExercise.exerciseDetails;

            return BlocBuilder<CameraDetectionCubit, CameraDetectionState>(
              builder: (context, cameraState) {
                final possibleSets = exerciseState.sets.where((set) => !set.isDone && !set.isBusy).toList();
                final selectedSet = possibleSets.firstWhereOrNull((set) => set.id == cameraState.selectedSetId);

                if (selectedSet == null && _setTextField.text.isNotEmpty) {
                  _setTextField.clear();
                } else if (selectedSet != null) {
                  _setTextField.text = t.camera_detection.selectedSetLabel(number: selectedSet.setNumber ?? '');
                }

                return DefaultBackground(
                  additionalAnimationsBehind: const [ParticlesWidget()],
                  body: ValueListenableBuilder(
                    valueListenable: _isDraggingPosePoint,
                    builder: (context, isDraggingPosePoint, child) {
                      return CustomScrollView(
                        physics: isDraggingPosePoint ? const NeverScrollableScrollPhysics() : null,
                        slivers: [
                          DefaultSliverAppBar(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            title: t.camera_detection.title,
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            sliver: SliverToBoxAdapter(
                              child: VideoSection(
                                videoUrl: exerciseDetails.videoInstructionUrl,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(child: WorkoutSection(exercise: exerciseDetails)),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: SetSelectionField(
                                controller: _setTextField,
                                initialValue: selectedSet,
                                setList: possibleSets,
                                onChanged: (value) {
                                  context.read<CameraDetectionCubit>().selectSet(value.id);
                                  _setTextField.text = t.camera_detection.selectedSetLabel(
                                    number: value.setNumber ?? '',
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            sliver: SliverToBoxAdapter(
                              child: CameraDetectionImageSection(
                                state: cameraState,
                                onPickImage: () => _pickImage(context),
                                onPoseInteractionStart: () {
                                  _isDraggingPosePoint.value = true;
                                },
                                onPoseInteractionEnd: () {
                                  _isDraggingPosePoint.value = false;
                                },
                              ),
                            ),
                          ),
                          const AppBottomPaddingWidget.sliver(),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<CameraDetectionCubit, CameraDetectionState>(
          builder: (context, cameraState) {
            switch (cameraState) {
              case CameraDetectionInitial():
                return const SizedBox.shrink();

              case CameraDetectionImageSelected():
              case CameraDetectionAnalyzing():
              case CameraDetectionAdjusting():
              case CameraDetectionSavingResult():
                return AppBottomPaddingWidget(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PrimaryButton(
                      text: _primaryButtonText(cameraState),
                      iconAsset: _primaryButtonIcon(cameraState),
                      onPressed: _primaryButtonAction(context, cameraState),
                    ),
                  ).animateEntrance(),
                );
            }
          },
        ),
      ),
    );
  }

  void _onCameraDetectionStateChanged(BuildContext context, CameraDetectionState state) {
    switch (state) {
      case CameraDetectionAnalyzing():
        _showAnalyzeDialog(context, state);

      case CameraDetectionAdjusting(:final error) when error != null:
        _closeAnalyzeDialog(context);
        _showRetryDialog(context, error);

      case CameraDetectionInitial() ||
          CameraDetectionImageSelected() ||
          CameraDetectionAdjusting() ||
          CameraDetectionSavingResult():
        _closeAnalyzeDialog(context);
    }
  }

  void _showAnalyzeDialog(BuildContext context, CameraDetectionAnalyzing state) {
    if (_isAnalyzeDialogOpen) return;

    _isAnalyzeDialogOpen = true;
    final cubit = context.read<CameraDetectionCubit>();

    unawaited(
      AppDialog.show<void>(
        context,
        barrierDismissible: false,
        child: BlocProvider.value(
          value: cubit,
          child: AnalyzeImageDialog(
            imagePath: state.imagePath,
            originalImageSize: state.originalImageSize,
            onClosePressed: cubit.cancelAnalysis,
          ),
        ),
      ).whenComplete(() {
        _isAnalyzeDialogOpen = false;
      }),
    );
  }

  void _closeAnalyzeDialog(BuildContext context) {
    if (!_isAnalyzeDialogOpen) return;

    _isAnalyzeDialogOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showRetryDialog(BuildContext context, String error) {
    if (_isRetryDialogOpen) return;

    _isRetryDialogOpen = true;
    final cubit = context.read<CameraDetectionCubit>();

    unawaited(
      AppDialog.show<bool?>(
        context,
        child: AnalysisFailedDialog(
          onTryAgainPressed: cubit.retryAnalysis,
        ),
      ).whenComplete(() {
        final currentState = cubit.state;

        if (currentState case CameraDetectionAdjusting(error: final currentError) when currentError != null) {
          cubit.returnToSelectedImage();
        }

        _isRetryDialogOpen = false;
      }),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await ImagePickerService.pickAndCrop(
      context,
      availableOptions: [
        PickerOption.takePhoto,
        PickerOption.selectPhoto,
      ],
      dialogData: ImageSourcePickerDialogData(
        title: t.camera_detection.title,
        takePhotoTitle: t.camera_detection.useCamera,
        selectPhotoTitle: t.camera_detection.uploadImage,
      ),
    );
    final pickedData = result.orNull;
    final file = pickedData?.file;

    if (!context.mounted || file == null) return;

    await context.read<CameraDetectionCubit>().setImage(file);
  }

  String _primaryButtonText(CameraDetectionState state) {
    return switch (state) {
      CameraDetectionAdjusting() => t.camera_detection.confirm,
      CameraDetectionSavingResult() => t.camera_detection.confirming,
      _ => t.camera_detection.analyzeImage,
    };
  }

  String? _primaryButtonIcon(CameraDetectionState state) {
    return switch (state) {
      CameraDetectionAdjusting() || CameraDetectionSavingResult() => null,
      _ => Assets.images.icons.magicWand,
    };
  }

  VoidCallback? _primaryButtonAction(BuildContext context, CameraDetectionState state) {
    return switch (state) {
      CameraDetectionImageSelected() => () => context.read<CameraDetectionCubit>().analyzeImage(
        preset: _poseDetectionPreset(context),
      ),
      CameraDetectionAdjusting() when state.canConfirm => () => _confirmResult(context, state),
      _ => null,
    };
  }

  PoseDetectionPreset _poseDetectionPreset(BuildContext context) {
    return context.read<ActiveExerciseCubit>().programExercise.exerciseDetails.poseDetectionPreset ??
        PoseDetectionPreset.legs;
  }

  void _confirmResult(BuildContext context, CameraDetectionAdjusting state) {
    final cameraCubit = context.read<CameraDetectionCubit>();
    final angle = cameraCubit.startSavingResult();
    final selectedSetId = state.selectedSetId;

    if (angle == null || selectedSetId == null) return;

    final activeExerciseCubit = context.read<ActiveExerciseCubit>();
    final selectedSet = activeExerciseCubit.state.sets.firstWhereOrNull((set) => set.id == selectedSetId);

    if (selectedSet == null) {
      cameraCubit.selectSet(null);
      return;
    }

    activeExerciseCubit.updateSet(
      selectedSetId,
      selectedSet.copyWith(degrees: angle.roundToDouble()),
    );

    toastification.showSimpleToast(
      t.camera_detection.successfullyUpdated,
    );

    cameraCubit.reset();
  }
}
