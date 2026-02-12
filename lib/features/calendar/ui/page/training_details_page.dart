import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/int_extension.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/features/active_workout/ui/widgets/exercise_results/result_exercise_data.dart';
import 'package:reforge/features/active_workout/ui/widgets/exercise_results/result_exercise_header.dart';
import 'package:reforge/features/active_workout/ui/widgets/previous_result_dialog.dart';
import 'package:reforge/features/calendar/domain/mock/genertor.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';

import 'package:reforge/features/workout_common/ui/widgets/workout_list_tile.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
import 'package:reforge/shared/horizontal_xp_bar.dart';

import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TrainingDetailsPage extends StatelessWidget {
  const TrainingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      body: DefaultBackground(body: TrainingDetailsBody()),
    );
  }
}

class TrainingDetailsBody extends StatelessWidget {
  const TrainingDetailsBody({super.key});
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          DefaultSliverAppBar(
            onPressed: () {
              Navigator.of(context).pop();
            },
            title: 'Notification',
          ),
          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16, top: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Overview',
                style: subheadH2Medium.copyWith(color: appTheme.beige100),
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: const TotalDurationTile(
                trainingDuration: 1000,
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: const XpTile(
                progress: 0.5,
                xp: 1000,
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Workout info',
                style: subheadH2Medium.copyWith(color: appTheme.beige100),
              ),
            ),
          ),

          SliverPadding(
            padding: horizontalPadding.copyWith(bottom: 16),
            sliver: SliverList.separated(
              itemCount: 3,
              itemBuilder: (context, index) {
                return WorkoutInfoTile(
                  result: MockExerciseGenerator.generateList().first,
                  system: MeasurementSystem.metric,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TotalDurationTile extends StatelessWidget {
  const TotalDurationTile({required this.trainingDuration, super.key});

  final int trainingDuration;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);
    final duration = trainingDuration.durationFormatted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: Row(
        children: [
          AppSvgListTileIcon(
            asset: Assets.images.icons.timer,
            color: appTheme.beige100,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'Total Duration',
                  style: subheadH3Medium.copyWith(color: appTheme.beige100),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${duration.hours}', style: primaryStyle),
                      TextSpan(
                        text: ' ${context.t.timer.hours_short} ',
                        style: secondaryStyle,
                      ),
                      TextSpan(text: '${duration.minutes}', style: primaryStyle),
                      TextSpan(
                        text: ' ${context.t.timer.minutes_short}',
                        style: secondaryStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class XpTile extends StatelessWidget {
  const XpTile({required this.progress, required this.xp, super.key});
  final int xp;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            context.t.home.xp_earned,
            style: subheadH3Medium.copyWith(color: appTheme.beige100),
          ),
          const SizedBox(height: 12),
          Skeleton.leaf(
            child: Row(
              children: [
                Expanded(
                  child: HorizontalXPBar(
                    progress: progress,
                    barSize: const Size.fromHeight(20),
                  ),
                ),
                const SizedBox(width: 10),
                Text(XpFormatter.compact(xp), style: subheadH5Medium.copyWith(color: appTheme.beige100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutInfoTile extends StatefulWidget {
  const WorkoutInfoTile({
    required this.result,
    required this.system,
    super.key,
  });

  final PreviousExerciseResult result;
  final MeasurementSystem system;
  @override
  State<WorkoutInfoTile> createState() => _WorkoutInfoTileState();
}

class _WorkoutInfoTileState extends State<WorkoutInfoTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final appTheme = context.appTheme;

    final wsets = result.sets
        .mapIndexed(
          (i, set) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ResultExerciseData(
              metrics: result.metrics,
              set: set,
              system: widget.system,
              setNumber: i + 1,
            ),
          ),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StaticWorkoutTile(
          onTap: _handleTap,
          title: result.name,
          description: result.description,
          imageUrl: result.imageUrl,
          icon: RotationTransition(
            turns: _iconTurns,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: appTheme.beige200,
              size: 32,
            ),
          ),
        ),

        SizeTransition(
          sizeFactor: _controller,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              children: [
                if (result.metrics.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ResultExerciseHeader(
                      metrics: result.metrics,
                      system: widget.system,
                    ),
                  ),

                ...wsets,

                if (result.notes != null && result.notes!.isNotEmpty)
                  NotesSection(
                    notes: result.notes,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
