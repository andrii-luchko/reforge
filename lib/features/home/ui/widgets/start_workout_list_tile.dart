import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';

class StartWorkoutListTile extends StatelessWidget {
  const StartWorkoutListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leadingIcon: AppSvgListTileIcon(
        asset: Assets.images.icons.dumbbell,
        color: context.appTheme.beige100,
      ),
      title: 'Forge Today’s Workout',
      subtitle: 'Start workout',
      onTap: () async {
        await const WorkoutDetailsPageRoute().push<void>(context);
      },
    );
  }
}
