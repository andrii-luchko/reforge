import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/app_svg_list_tile_icon.dart';
import 'package:reforge/shared/centered_title_section.dart';

class HomeWorkoutResultEmpty extends StatelessWidget {
  const HomeWorkoutResultEmpty({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.appTheme.beige800,
                  shape: BoxShape.circle,
                ),
                child: AppSvgListTileIcon.asset(
                  asset: Assets.images.icons.lock,
                  color: context.appTheme.beige100,
                ),
              ),
              const SizedBox(height: 24),
              CenteredTitleSection(
                title: t.home.workout_results.empty_data,
                subtitle: t.home.workout_results.empty_data_message,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
