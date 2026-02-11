import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/ui/widgets/common_heder_delegate.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/ui/widgets/stats_period_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutResultHeader extends StatelessWidget {
  const WorkoutResultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: CommonHeaderDelegate(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t.home.workout_results.title,
              style: subheadH2Medium,
            ),
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (prev, curr) => prev.period != curr.period,
              builder: (context, state) {
                return StatsPeriodSelector(
                  selectedPeriod: state.period,
                  onChanged: (newPeriod) {
                    context.read<HomeCubit>().changePeriod(newPeriod);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
