// ignore_for_file: no_empty_block
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';

import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/radio_button_option.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/error_shake_widget.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

typedef _FactionSelection = ({Faction? primary, Faction? secondary});

class ChangeFactionPage extends StatelessWidget {
  const ChangeFactionPage({
    required this.initialFactions,
    super.key,
  });

  final List<Faction> initialFactions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userCubit = context.read<UserCubit>();
        final primary = initialFactions.firstOrNull;
        final secondaryCandidate = initialFactions.length > 1 ? initialFactions[1] : null;
        final secondary = secondaryCandidate == primary ? null : secondaryCandidate;

        return GenericValidationCubit<_FactionSelection>(
          initialValue: (primary: primary, secondary: secondary),
          validator: (value) {
            if (value.primary == null) {
              return t.settings.factionsEmpty;
            }
            return null;
          },
          onSave: (selection) => _onSave(selection, userCubit),
        );
      },
      child: GenericSaveListener<_FactionSelection>(
        child: BaseSettingsEditPage(
          title: WorkoutSettings.faction.title(t),
          body: const ChangeFactionContent(),
        ),
      ),
    );
  }

  Future<void> _onSave(_FactionSelection selection, UserCubit cubit) async {
    final primary = selection.primary;
    if (primary == null) return;

    final result = await cubit.updateFactions(
      mainFaction: primary.id,
      secondFaction: selection.secondary == primary ? null : selection.secondary?.id,
    );

    if (result case Failure(error: final e)) {
      throw e;
    }
  }
}

class ChangeFactionContent extends StatelessWidget {
  const ChangeFactionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericValidationCubit<_FactionSelection>, GenericValidationState<_FactionSelection>>(
      builder: (context, state) {
        final cubit = context.read<GenericValidationCubit<_FactionSelection>>();
        final selection = state.value;

        final error = state is GenericValidationError ? state.error : null;

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.factionSelectionTitle,
                    style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.settings.factionSelectionDescription,
                    style: bodyLRegular.copyWith(color: context.appTheme.beige600),
                  ),
                  const SizedBox(height: 16),
                  for (final faction in Faction.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FactionRoleOption(
                        faction: faction,
                        isPrimary: faction == selection.primary,
                        isSecondary: faction == selection.secondary,
                        onTap: () {
                          if (faction == selection.primary) return;

                          if (faction == selection.secondary) {
                            cubit.onChanged((primary: faction, secondary: selection.primary));
                            return;
                          }

                          cubit.onChanged((primary: selection.primary, secondary: faction));
                        },
                        onRemoveSecondary: () {
                          cubit.onChanged((primary: selection.primary, secondary: null));
                        },
                      ),
                    ),
                  ErrorShakeWidget(
                    shake: state is GenericValidationError,
                    error: error,
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SecondaryButton(
                  text: t.common.save_changes_button,
                  onPressed: cubit.save,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FactionRoleOption extends StatelessWidget {
  const _FactionRoleOption({
    required this.faction,
    required this.isPrimary,
    required this.isSecondary,
    required this.onTap,
    required this.onRemoveSecondary,
  });

  final Faction faction;
  final bool isPrimary;
  final bool isSecondary;
  final VoidCallback onTap;
  final VoidCallback onRemoveSecondary;

  @override
  Widget build(BuildContext context) {
    final roleTag = isPrimary ? context.appTheme.orange500 : null;

    return Column(
      spacing: 8,
      children: [
        RadioButtonOption(
          title: faction.title(t),
          description: faction.description(t),
          isSelected: isPrimary || isSecondary,
          radioColor: roleTag,
          onTap: onTap,
        ),
      ],
    );
  }
}
