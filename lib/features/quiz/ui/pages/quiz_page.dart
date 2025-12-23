import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/main_goal.dart';
import 'package:reforge/features/quiz/domain/measure_system.dart';
import 'package:reforge/features/quiz/ui/widgets/date_piker.dart';
import 'package:reforge/features/quiz/ui/widgets/measure_switcher.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/shaders/particles_shader.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/step_progress_indicator.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppAppBar(
        onPressed: () {},
        actions: [
          Padding(
            padding: const .only(right: 16),
            child: Text(
              t.quiz.header,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned.fill(child: ParticlesShaderWidget()),
            Positioned.fill(
              child: Image.asset(
                Assets.images.png.smoke.path,
                fit: .fill,
                opacity: const AlwaysStoppedAnimation<double>(0.5),
              ),
            ),

            Positioned.fill(
              child: Image.asset(
                Assets.images.png.noiseAndTexture.path,
                fit: .fill,
              ),
            ),

            Positioned.fill(
              child: SunRaysShaderWidget(
                color: appTheme.orange500,
                alignment: const Alignment(0, -1.2),
                intensity: 1,
                density: 5,
                rayLength: 0.6,
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const .symmetric(horizontal: 16),
                child: SafeArea(child: QuizForm()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizForm extends StatefulWidget {
  const QuizForm({super.key});

  @override
  State<QuizForm> createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  final PageController _controller = PageController();

  int currentStep = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: StepProgressIndicator(
            currentStep: currentStep,
            totalSteps: 7,
          ),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Expanded(child: DateBirthStep()),

              Expanded(child: MeasurementSystemStep()),
              Expanded(child: MainGoalStep()),

              Expanded(child: TrainLevelStep()),
              Expanded(child: WorkoutFrequencyStep()),
              Expanded(child: SelectMainFaction()),
              Expanded(child: SelectSecondFaction()),
            ],
          ),
        ),

        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: t.quiz.back_button,
                onPressed: () {
                  setState(() {
                    if (currentStep > 1) currentStep--;
                  });
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: t.quiz.next_button,
                onPressed: () {
                  setState(() {
                    if (currentStep < 7) currentStep++;
                  });
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DateBirthStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.date_of_birth.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        LabeledAppTextField(
          label: t.quiz.steps.date_of_birth.select_date_label,
          field: FieldDatePicker(
            onDateSelected: (value) {},
          ),
        ),
      ],
    );
  }
}

class MeasurementSystemStep extends StatefulWidget {
  const MeasurementSystemStep({super.key});

  @override
  State<MeasurementSystemStep> createState() => _MeasurementSystemStepState();
}

class _MeasurementSystemStepState extends State<MeasurementSystemStep> {
  MeasurementSystem _selectedMeasure = MeasurementSystem.metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.measurement_system.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),

        MeasureSwitcher(
          selectedMeasure: _selectedMeasure,
          onSelected: (value) {
            setState(() {
              _selectedMeasure = value;
            });
          },
        ),
      ],
    );
  }
}

class MainGoalStep extends StatefulWidget {
  const MainGoalStep({super.key});

  @override
  State<MainGoalStep> createState() => _MainGoalStepState();
}

class _MainGoalStepState extends State<MainGoalStep> {
  MainGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.main_goal.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        FitnessGoalSelector(
          selectedGoal: _selectedGoal,
          onGoalChanged: (goal) {
            setState(() {
              _selectedGoal = goal;
            });
          },
        ),
      ],
    );
  }
}

class FitnessGoalSelector extends StatelessWidget {
  const FitnessGoalSelector({
    required this.selectedGoal,
    required this.onGoalChanged,
    super.key,
  });

  final MainGoal? selectedGoal;
  final ValueChanged<MainGoal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: MainGoal.values.map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: goal.title(t),
            description: goal.description(t),
            isSelected: selectedGoal == goal,
            onTap: () => onGoalChanged(goal),
          ),
        );
      }).toList(),
    );
  }
}

class RadioButtonOption extends StatelessWidget {
  const RadioButtonOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.description,
    super.key,
  });

  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.appTheme.beige900,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              center: const Alignment(-0.88, -0.784),
              radius: 4.946,
              colors: [
                context.appTheme.orange600.withValues(alpha: 0),
                context.appTheme.orange600.withValues(alpha: 0),
                context.appTheme.orange600.withValues(alpha: 0.6),
              ],
              stops: const [0.0, 0.6248, 1.0],
            ),

            border: Border.all(
              color: appTheme.strokeCard,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: subheadH3Medium.copyWith(color: appTheme.beige100),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: subheadH6Regular.copyWith(color: appTheme.beige600),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.beige700,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appTheme.beige100,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TrainingLevel {
  beginner,
  intermediate,
  advanced,
}

extension TrainingLevelExtension on TrainingLevel {
  String title(Translations translations) {
    switch (this) {
      case TrainingLevel.beginner:
        return translations.quiz.steps.training_level.beginner.title;
      case TrainingLevel.intermediate:
        return translations.quiz.steps.training_level.intermediate.title;
      case TrainingLevel.advanced:
        return translations.quiz.steps.training_level.advanced.title;
    }
  }

  String description(Translations translations) {
    switch (this) {
      case TrainingLevel.beginner:
        return translations.quiz.steps.training_level.beginner.description;
      case TrainingLevel.intermediate:
        return translations.quiz.steps.training_level.intermediate.description;
      case TrainingLevel.advanced:
        return translations.quiz.steps.training_level.advanced.description;
    }
  }
}

class TrainLevelStep extends StatefulWidget {
  const TrainLevelStep({super.key});

  @override
  State<TrainLevelStep> createState() => _TrainLevelStepState();
}

class _TrainLevelStepState extends State<TrainLevelStep> {
  TrainingLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.training_level.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        TrainingLevelSelector(
          selectedLevel: _selectedLevel,
          onLevelChanged: (level) {
            setState(() {
              _selectedLevel = level;
            });
          },
        ),
      ],
    );
  }
}

class TrainingLevelSelector extends StatelessWidget {
  const TrainingLevelSelector({
    required this.selectedLevel,
    required this.onLevelChanged,
    super.key,
  });

  final TrainingLevel? selectedLevel;
  final ValueChanged<TrainingLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: TrainingLevel.values.map((level) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: level.title(t),
            description: level.description(t),
            isSelected: selectedLevel == level,
            onTap: () => onLevelChanged(level),
          ),
        );
      }).toList(),
    );
  }
}

class WorkoutFrequencyStep extends StatelessWidget {
  const WorkoutFrequencyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.workout_frequency.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_days_label,
          field: PortalSelectField(
            hintText: t.quiz.steps.workout_frequency.select_days_hint,
            contentBuilder: (_, _) {
              return Container(
                height: 200,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_specific_days_label,
          field: PortalSelectField(
            hintText: t.quiz.steps.workout_frequency.select_specific_days_hint,
            contentBuilder: (_, _) {
              return Container(
                height: 200,
              );
            },
          ),
        ),
      ],
    );
  }
}

enum Faction {
  gakki,
  gyohyo,
  serien,
}

extension FactionExtension on Faction {
  String title(Translations t) {
    switch (this) {
      case Faction.gakki:
        return t.common.factions.gakki;
      case Faction.gyohyo:
        return t.common.factions.gyohyo;
      case Faction.serien:
        return t.common.factions.serien;
    }
  }
}

class SelectMainFaction extends StatefulWidget {
  const SelectMainFaction({super.key});

  @override
  State<SelectMainFaction> createState() => _SelectMainFactionState();
}

class _SelectMainFactionState extends State<SelectMainFaction> {
  Faction? _selectedFaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.main_faction.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        Text(
          t.quiz.steps.main_faction.subtitle,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
        const SizedBox(height: 32),
        FactionSelector(
          selectedFaction: _selectedFaction,
          onFactionChanged: (faction) {
            setState(() {
              _selectedFaction = faction;
            });
          },
        ),
      ],
    );
  }
}

class SelectSecondFaction extends StatefulWidget {
  const SelectSecondFaction({super.key});

  @override
  State<SelectSecondFaction> createState() => _SelectSecondFactionState();
}

class _SelectSecondFactionState extends State<SelectSecondFaction> {
  Faction? _selectedFaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          t.quiz.steps.second_faction.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 16),
        Text(
          t.quiz.steps.second_faction.subtitle,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
        const SizedBox(height: 32),
        FactionSelector(
          selectedFaction: _selectedFaction,
          onFactionChanged: (faction) {
            setState(() {
              _selectedFaction = faction;
            });
          },
        ),
      ],
    );
  }
}

class FactionSelector extends StatelessWidget {
  const FactionSelector({
    required this.selectedFaction,
    required this.onFactionChanged,
    this.isMainFaction = true,
    super.key,
  });

  final Faction? selectedFaction;
  final ValueChanged<Faction> onFactionChanged;
  final bool isMainFaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Faction.values.map((faction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioButtonOption(
            title: faction.title(t),
            isSelected: selectedFaction == faction,
            onTap: () => onFactionChanged(faction),
          ),
        );
      }).toList(),
    );
  }
}
