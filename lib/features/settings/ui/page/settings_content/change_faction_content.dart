// ignore_for_file: no_empty_block
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/faction_selector.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/error_shake_widget.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';

class ChangeFactionPage extends StatelessWidget {
  const ChangeFactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<List<Faction>>(
        initialValue: [],
        validator: (value) {
          if (value.isEmpty) {
            return 'You nee to select at least one Faction';
          }
          return null;
        },
        onSave: (_) async {},
      ),
      child: BaseSettingsEditPage(
        title: WorkoutSettings.faction.title(t),
        body: const ChangeFactionContent(),
      ),
    );
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
