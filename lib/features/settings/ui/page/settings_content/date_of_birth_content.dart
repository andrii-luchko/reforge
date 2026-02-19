// ignore_for_file: no_empty_block
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/date_of_birth.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/quiz/ui/widgets/date_text_field.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class DateOfBirthPage extends StatelessWidget {
  const DateOfBirthPage({required this.dateOfBirth, super.key});

  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();

    return BlocProvider(
      create: (context) => GenericValidationCubit<DateTime?>(
        initialValue: dateOfBirth,
        validator: validateDateOfBirth,
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<DateTime?>(
        child: BaseSettingsEditPage(
          title: ProfileSettings.dateOfBirth.title(t),
          body: const DateOfBirthContent(),
        ),
      ),
    );
  }

  Future<void> onSave(DateTime? value, UserCubit cubit) async {
    final result = await cubit.updateProfile(
      PatchProfileRequest(dateOfBirth: value),
    );
    if (result case ErrorR(error: final e)) {
      throw e;
    }
  }
}

class DateOfBirthContent extends StatelessWidget {
  const DateOfBirthContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenericValidationCubit<DateTime?>>();
    return SliverMainAxisGroup(
      slivers: [
        BlocSelector<
          GenericValidationCubit<DateTime?>,
          GenericValidationState<DateTime?>,
          ({DateTime? dateTime, String? error})
        >(
          selector: (state) {
            final error = state is GenericValidationError ? state.error : null;
            return (dateTime: state.value, error: error);
          },
          builder: (context, dateData) {
            return SliverToBoxAdapter(
              child: LabeledAppTextField(
                label: t.quiz.steps.date_of_birth.select_date_label,
                field: DateInputField(
                  initialDate: dateData.dateTime,
                  errorText: dateData.error,
                  onDateSelected: cubit.onChanged,
                ),
              ),
            );
          },
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
  }
}
