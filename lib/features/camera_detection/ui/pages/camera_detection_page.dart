import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/core/photo/service/image_picker_service.dart';
import 'package:reforge/core/photo/ui/image_source_picker_dialog.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/camera_detection/controller/camera_detection_cubit.dart';
import 'package:reforge/features/camera_detection/domain/enums/pose_detection_preset.dart';
import 'package:reforge/features/camera_detection/ui/widgets/analyze_image_dialog.dart';
import 'package:reforge/features/camera_detection/ui/widgets/contained_image_frame.dart';
import 'package:reforge/features/camera_detection/ui/widgets/pose_detection_image.dart';
import 'package:reforge/features/camera_detection/ui/widgets/set_selection_field.dart';
import 'package:reforge/features/camera_detection/ui/widgets/upload_image_widget.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/video_section.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/text_button.dart';
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
                  _setTextField.text = 'Set ${selectedSet.setNumber}';
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
                            title: 'Camera',
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
                                  _setTextField.text = 'Set ${value.setNumber}';
                                },
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            sliver: SliverToBoxAdapter(
                              child: ImageSection(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            children: [
              const DefaultDialogHeader(title: 'Analysis failed'),
              const SizedBox(
                height: 16,
              ),
              Text(
                'For accurate analysis, make sure your entire body is visible in the photo, including your head, arms, and legs.',
                textAlign: TextAlign.center,
                style: bodyLRegular.copyWith(color: context.appTheme.beige600),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Try again',
                iconAsset: Assets.images.icons.upload,
                onPressed: cubit.retryAnalysis,
              ),
            ],
          ),
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
      dialogData: const ImageSourcePickerDialogData(
        title: 'Camera',
        takePhotoTitle: 'Use camera',
        selectPhotoTitle: 'Upload image',
      ),
    );
    final pickedData = result.orNull;
    final file = pickedData?.file;

    if (!context.mounted || file == null) return;

    await context.read<CameraDetectionCubit>().setImage(file);
  }

  String _primaryButtonText(CameraDetectionState state) {
    return switch (state) {
      CameraDetectionAdjusting() => 'Confirm',
      CameraDetectionSavingResult() => 'Confirming',
      _ => 'Analyze image',
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
      'Successfully updated',
    );

    cameraCubit.reset();
  }
}

class ImageSection extends StatelessWidget {
  const ImageSection({
    required this.state,
    required this.onPickImage,
    required this.onPoseInteractionStart,
    required this.onPoseInteractionEnd,
    super.key,
  });

  final CameraDetectionState state;
  final VoidCallback onPickImage;
  final VoidCallback onPoseInteractionStart;
  final VoidCallback onPoseInteractionEnd;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('Your image', style: subheadH3Medium.copyWith(color: context.appTheme.beige100)),

              if (state is CameraDetectionAdjusting && (state as CameraDetectionAdjusting).hasManualChange) ...[
                AppTextButton(
                  onPressed: context.read<CameraDetectionCubit>().resetPoints,
                  text: 'Reset points',
                  assetPath: Assets.images.icons.close,
                ),
              ],
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 316 / 415,
          child: CustomPaint(
            painter: DashedBorderPainter(color: appTheme.strokeCard, strokeWidth: 1, radius: 20),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _ImageContent(
                state: state,
                onPickImage: onPickImage,
                onPoseInteractionStart: onPoseInteractionStart,
                onPoseInteractionEnd: onPoseInteractionEnd,
              ),
            ),
          ),
        ),
        if (state.hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextButton(
                  onPressed: onPickImage,
                  text: 'Replace image',
                  assetPath: Assets.images.icons.reload,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({
    required this.state,
    required this.onPickImage,
    required this.onPoseInteractionStart,
    required this.onPoseInteractionEnd,
  });

  final CameraDetectionState state;
  final VoidCallback onPickImage;
  final VoidCallback onPoseInteractionStart;
  final VoidCallback onPoseInteractionEnd;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CameraDetectionInitial() => UploadImageWidget(onPressed: onPickImage),
      CameraDetectionImageSelected(:final imagePath, :final originalImageSize) => _SelectedImage(
        imagePath: imagePath,
        originalImageSize: originalImageSize,
      ),
      CameraDetectionAnalyzing(:final imagePath, :final originalImageSize) => _SelectedImage(
        imagePath: imagePath,
        originalImageSize: originalImageSize,
        isLoading: true,
      ),
      CameraDetectionAdjusting(
        :final imagePath,
        :final originalImageSize,
        :final points,
        :final angleResult,
      ) =>
        PoseDetectionImage(
          imagePath: imagePath,
          originalImageSize: originalImageSize,
          points: points,
          angleResult: angleResult,
          onPointMoved: (pointNumber, position) {
            context.read<CameraDetectionCubit>().movePoint(
              pointNumber: pointNumber,
              position: position,
            );
          },
          onInteractionStart: onPoseInteractionStart,
          onInteractionEnd: onPoseInteractionEnd,
        ),
      CameraDetectionSavingResult(
        :final imagePath,
        :final originalImageSize,
        :final points,
        :final angleResult,
      ) =>
        PoseDetectionImage(
          imagePath: imagePath,
          originalImageSize: originalImageSize,
          points: points,
          angleResult: angleResult,
          onPointMoved: (_, _) {},
          onInteractionStart: onPoseInteractionStart,
          onInteractionEnd: onPoseInteractionEnd,
        ),
    };
  }
}

class _SelectedImage extends StatelessWidget {
  const _SelectedImage({
    required this.imagePath,
    required this.originalImageSize,
    this.isLoading = false,
  });

  final String imagePath;
  final Size originalImageSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ContainedImageFrame(
      imagePath: imagePath,
      originalImageSize: originalImageSize,
      builder: (context, transform) {
        if (!isLoading) return const SizedBox.shrink();

        return Positioned.fromRect(
          rect: transform.imageRect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.appTheme.beige1000.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
