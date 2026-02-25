import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/features/calendar/controllers/training_details/training_details_cubit.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/calendar/ui/widgets/total_duration_tile.dart';
import 'package:reforge/features/calendar/ui/widgets/workout_info_tile.dart';
import 'package:reforge/features/calendar/ui/widgets/xp_tile.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
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
    return BlocBuilder<TrainingDetailsCubit, TrainingDetailsState>(
      builder: (context, state) {
        return state.map(
          initial: (_) => const _TrainingDetailsLoadingView(),
          loading: (_) => const _TrainingDetailsLoadingView(),
          loaded: (s) => _TrainingDetailsContentView(data: s.data),
          error: (s) => _TrainingDetailsErrorView(message: s.message),
        );
      },
    );
  }
}

class _TrainingDetailsLoadingView extends StatelessWidget {
  const _TrainingDetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SafeArea(
      top: false,
      bottom: false,
      child: Skeletonizer(
        child: CustomScrollView(
          slivers: [
            DefaultSliverAppBar(
              onPressed: () => Navigator.of(context).pop(),
              title: t.training_details.title,
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16, top: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  t.training_details.overview,
                  style: subheadH2Medium.copyWith(color: appTheme.beige100),
                ),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: const SliverToBoxAdapter(
                child: TotalDurationTile(trainingDuration: 0),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: const SliverToBoxAdapter(
                child: XpTile(progress: 0.5, xp: 0),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  t.training_details.workout_info,
                  style: subheadH2Medium.copyWith(color: appTheme.beige100),
                ),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverList.separated(
                itemCount: 2,
                itemBuilder: (context, index) => WorkoutInfoTile(
                  result: PreviousExerciseResult(
                    name: t.common.loading,
                    description: t.common.loadingDescription,
                  ),
                  system: MeasurementSystem.metric,
                ),
                separatorBuilder: (_, _) => const SizedBox(height: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingDetailsErrorView extends StatelessWidget {
  const _TrainingDetailsErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        slivers: [
          DefaultSliverAppBar(
            onPressed: () => Navigator.of(context).pop(),
            title: t.training_details.title,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: TrainingDetailsBody.horizontalPadding,
              child: Center(
                child: Text(
                  message,
                  style: subheadH3Medium.copyWith(color: context.appTheme.beige600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingDetailsContentView extends StatelessWidget {
  const _TrainingDetailsContentView({required this.data});

  final TrainingDetailsEntity data;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return SafeArea(
      top: false,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<TrainingDetailsCubit>().refresh(),
        child: CustomScrollView(
          slivers: [
            DefaultSliverAppBar(
              onPressed: () => Navigator.of(context).pop(),
              title: t.training_details.trainingDateTitle(date: data.date.toDotString()),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16, top: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  t.training_details.overview,
                  style: subheadH2Medium.copyWith(color: appTheme.beige100),
                ),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverToBoxAdapter(
                child: TotalDurationTile(trainingDuration: data.duration).animateEntrance(),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverToBoxAdapter(
                child: XpTile(
                  progress: 0.5,
                  xp: data.totalXpEarned,
                ).animateEntrance(),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  t.training_details.workout_info,
                  style: subheadH2Medium.copyWith(color: appTheme.beige100),
                ),
              ),
            ),
            SliverPadding(
              padding: TrainingDetailsBody.horizontalPadding.copyWith(bottom: 16),
              sliver: SliverList.separated(
                itemCount: data.exercises.length,
                itemBuilder: (context, index) {
                  return WorkoutInfoTile(
                    result: data.exercises[index],
                    system: data.measurementSystem,
                  ).animateEntrance();
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
