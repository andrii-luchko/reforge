import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_start_intent.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';

class FreeRunListTile extends StatefulWidget {
  const FreeRunListTile({super.key});

  @override
  State<FreeRunListTile> createState() => _FreeRunListTileState();
}

class _FreeRunListTileState extends State<FreeRunListTile> {
  var _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.t.home.free_run.title,
      hint: context.t.home.free_run.subtitle,
      child: AppListTile(
        leadingIcon: AppSvgListTileIcon.asset(
          asset: Assets.images.icons.myLocation,
          color: context.appTheme.beige100,
        ),
        title: context.t.home.free_run.title,
        subtitle: context.t.home.free_run.subtitle,
        onTap: _isProcessing ? null : _handleTap,
      ),
    );
  }

  Future<void> _handleTap() async {
    setState(() => _isProcessing = true);
    context.read<HomeCubit>().onFreeRunTap();
    try {
      await const WorkoutDetailsPageRoute(
        intent: WorkoutStartIntent.freeRun,
      ).push<void>(context);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
