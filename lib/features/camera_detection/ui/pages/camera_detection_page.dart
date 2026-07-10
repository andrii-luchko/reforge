import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/media_query_extension.dart';
import 'package:reforge/core/photo/service/image_picker_service.dart';
import 'package:reforge/core/photo/ui/image_source_picker_dialog.dart';
import 'package:reforge/features/active_workout/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/camera_detection/ui/widgets/upload_image_widget.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_section.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/video_section.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/app_bottom_padding_widget.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/text_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({super.key});

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  final TextEditingController _setTextField = TextEditingController();

  final ValueNotifier<WorkoutSet?> _selectedSet = ValueNotifier(null);

  @override
  void dispose() {
    _setTextField.dispose();
    _selectedSet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
        builder: (context, state) {
          final cubit = context.read<ActiveExerciseCubit>();
          final programExercise = cubit.programExercise;
          final exerciseDetails = programExercise.exerciseDetails;

          return DefaultBackground(
            additionalAnimationsBehind: const [ParticlesWidget()],
            body: CustomScrollView(
              slivers: [
                DefaultSliverAppBar(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  title: 'Camera',
                ),
                SliverPadding(
                  padding: const .symmetric(horizontal: 16, vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: VideoSection(
                      videoUrl: exerciseDetails.videoInstructionUrl,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const .symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(child: WorkoutSection(exercise: exerciseDetails)),
                ),
                SliverPadding(
                  padding: const .symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: ValueListenableBuilder(
                      valueListenable: _selectedSet,
                      builder: (context, value, child) {
                        return SetSelectionField(
                          controller: _setTextField,
                          initialValue: value,
                          setList: state.sets.where((set) => !set.isDone && !set.isBusy).toList(),
                          onChanged: (value) {
                            _selectedSet.value = value;
                            _setTextField.text = 'Set ${value.setNumber} ';
                          },
                        );
                      },
                    ),
                  ),
                ),

                SliverPadding(
                  padding: .symmetric(horizontal: 16, vertical: 20),
                  sliver: SliverToBoxAdapter(
                    child: ImageSection(),
                  ),
                ),

                const AppBottomPaddingWidget.sliver(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomPaddingWidget(
        child: Padding(
          padding: const .symmetric(horizontal: 16),
          child: PrimaryButton(
            text: 'Analyze image',
            iconAsset: Assets.images.icons.magicWand,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class ImageSection extends StatelessWidget {
  const ImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const .only(bottom: 16),
          child: Text('Your image', style: subheadH3Medium.copyWith(color: context.appTheme.beige100)),
        ),

        AspectRatio(
          aspectRatio: 316 / 415,
          child: CustomPaint(
            painter: DashedBorderPainter(color: appTheme.strokeCard, strokeWidth: 1, radius: 20),
            child: Padding(
              padding: const .all(10),
              child: UploadImageWidget(
                onPressed: () async {
                  final result = await ImagePickerService.pickAndCrop(
                    context,
                    availableOptions: [
                      .takePhoto,
                      .selectPhoto,
                    ],
                    dialogData: ImageSourcePickerDialogData(
                      title: 'Camera',
                      takePhotoTitle: 'Use camera',
                      selectPhotoTitle: 'Upload image',
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        Padding(
          padding: const .only(top: 30),
          child: Center(
            child: AppTextButton(onPressed: () {}, text: 'Replace image', assetPath: Assets.images.icons.reload),
          ),
        ),
      ],
    );
  }
}

class SetSelectionField extends StatelessWidget {
  const SetSelectionField({
    required this.controller,
    required this.setList,
    required this.onChanged,
    this.initialValue,
    super.key,
  });
  final TextEditingController controller;
  final WorkoutSet? initialValue;
  final List<WorkoutSet> setList;
  final ValueChanged<WorkoutSet> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = subheadH3Medium.copyWith(color: context.appTheme.beige100);

    return LabeledAppTextField(
      label: t.workout.selectTier,
      field: PortalSelectField(
        controller: controller,
        hintText: 'Select set',
        heightFactor: setList.length > 3 ? 3 : 2,
        contentBuilder: (context, close) {
          if (setList.isEmpty) {
            return Center(
              child: Text(
                'No options to select',

                style: style,
              ),
            );
          }

          final possibleSets = setList
              .mapIndexed(
                (index, set) => Center(
                  child: Text('Set ${set.setNumber}', style: style),
                ),
              )
              .toList();

          final indexFound = initialValue == null ? 0 : setList.indexOf(initialValue!);

          final initialIndex = indexFound >= 0 ? indexFound : 0;

          return ValueScrollPicker(
            looping: false,
            initialItem: initialIndex,
            onSelectedItemChanged: (index) {
              onChanged(setList[index]);
            },
            children: possibleSets,
          );
        },
      ),
    );
  }
}
