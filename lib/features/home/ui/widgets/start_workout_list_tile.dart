import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';

class StartWorkoutListTile extends StatelessWidget {
  const StartWorkoutListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leadingIcon: AppSvgListTileIcon.asset(
        asset: Assets.images.icons.dumbbell,
        color: context.appTheme.beige100,
      ),
      title: context.t.home.start_workout.title,
      subtitle: context.t.home.start_workout.subtitle,
      onTap: () async {
        await context.read<UserCubit>().refreshUser();

        if (context.mounted) {
          context.read<HomeCubit>().onStartWorkoutTap();
          await const WorkoutDetailsPageRoute().push<void>(context);
        }
      },
    );
  }
}
