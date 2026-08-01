import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/exercise_session/controllers/exercise_swap/exercise_swap_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';

class ExerciseSwapHeader extends StatelessWidget {
  const ExerciseSwapHeader({required this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 56,
        leading: AppIconButton.icon(
          iconData: Icons.chevron_left_rounded,
          iconSize: 32,
          onPressed: onBack,
        ),
        actions: [
          Text(
            t.workout.swapSearchTitle,
            style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
            textAlign: TextAlign.end,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(16),
          child: SizedBox(),
        ),
      ),
    );
  }
}

class ExerciseSwapSearchHeader extends StatelessWidget {
  const ExerciseSwapSearchHeader({required this.isSwapping, super.key});

  final bool isSwapping;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AbsorbPointer(
              absorbing: isSwapping,
              child: AppTextField(
                hintText: t.workout.swapSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppSvgIcon(
                    asset: Assets.images.icons.search,
                    color: context.appTheme.beige100,
                  ),
                ),
                onChanged: context.read<ExerciseSwapCubit>().searchChanged,
              ),
            ),
          ),
          AbsorbPointer(
            absorbing: isSwapping,
            child: const _FactionFilters(),
          ),
        ],
      ),
    );
  }
}

class _FactionFilters extends StatelessWidget {
  const _FactionFilters();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExerciseSwapCubit, ExerciseSwapState, int?>(
      selector: (state) => state.factionId,
      builder: (context, selectedFactionId) {
        return SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _FactionChip(
                label: t.workout.allFactions,
                isSelected: selectedFactionId == null,
                onSelected: () => context.read<ExerciseSwapCubit>().factionChanged(null),
              ),
              for (final faction in Faction.values) ...[
                const SizedBox(width: 8),
                _FactionChip(
                  label: faction.title(t),
                  isSelected: selectedFactionId == faction.id,
                  onSelected: () => context.read<ExerciseSwapCubit>().factionChanged(faction.id),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FactionChip extends StatelessWidget {
  const _FactionChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Center(
      child: PressableAnimation(
        enabledFeedback: false,
        onTap: onSelected,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? appTheme.orange400 : appTheme.beige900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? appTheme.orange300 : appTheme.strokeCard,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Center(
            child: Text(
              label,
              style: subheadH5Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ),
      ),
    );
  }
}
