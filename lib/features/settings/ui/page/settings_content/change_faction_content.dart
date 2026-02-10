// ignore_for_file: no_empty_block
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';

import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/faction_selector.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/error_shake_widget.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

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

        return GenericValidationCubit<List<Faction>>(
          initialValue: initialFactions,
          validator: (value) {
            // if (value.isEmpty) {
            //   return 'You need to select at least one Faction';
            // }
            if (value.length < 2) {
              return 'You need to select at least 2 Factions';
            }
            return null;
          },
          onSave: (newFactions) => onSave(newFactions, userCubit),
        );
      },
      child: GenericSaveListener<List<Faction>>(
        child: BaseSettingsEditPage(
          title: WorkoutSettings.faction.title(t),
          body: const ChangeFactionContent(),
        ),
      ),
    );
  }

  Future<void> onSave(List<Faction> factions, UserCubit cubit) async {
    if (factions.isEmpty) return;
    Result<User> result;

    if (factions.length == 1) {
      result = await cubit.updateProfile(
        PatchProfileRequest(
          mainFaction: factions.first.id,
          secondFaction: 0,
        ),
      );
    } else {
      result = await cubit.updateProfile(
        PatchProfileRequest(mainFaction: factions.first.id, secondFaction: factions[1].id),
      );
    }

    if (result case ErrorR(error: final e)) {
      throw e;
    }
  }
}

class ChangeFactionContent extends StatelessWidget {
  const ChangeFactionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericValidationCubit<List<Faction>>, GenericValidationState<List<Faction>>>(
      builder: (context, state) {
        final cubit = context.read<GenericValidationCubit<List<Faction>>>();

        final currentFactions = state.value;
        final error = state.error;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                FactionSelector(
                  selectedFactions: currentFactions,
                  onFactionToggled: (selectedFaction) {
                    final updatedList = List<Faction>.from(currentFactions);

                    if (updatedList.contains(selectedFaction)) {
                      updatedList.remove(selectedFaction);
                    } else {
                      updatedList.add(selectedFaction);
                    }

                    cubit.onChanged(updatedList);
                  },
                ),

                ErrorShakeWidget(
                  shake: state is GenericValidationError,
                  error: error,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: t.common.save_changes_button,
              onPressed: cubit.save,
            ),
          ],
        );
      },
    );
  }
}
