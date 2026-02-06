// ignore_for_file: no_empty_block
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/validators/date_of_birth.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/features/quiz/ui/widgets/date_text_field.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class DateOfBirthPage extends StatelessWidget {
  const DateOfBirthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<DateTime?>(
        initialValue: null,
        validator: validateDateOfBirth,
        onSave: (_) async {},
      ),
      child: BaseSettingsEditPage(
        title: ProfileSettings.dateOfBirth.title(t),
        body: const DateOfBirthContent(),
      ),
    );
  }
}

class DateOfBirthContent extends StatelessWidget {
  const DateOfBirthContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<
          GenericValidationCubit<DateTime?>,
          GenericValidationState<DateTime?>,
          ({DateTime? dateTime, String? error})
        >(
          selector: (state) => (dateTime: state.value, error: state.error),
          builder: (context, dateData) {
            final cubit = context.read<GenericValidationCubit<DateTime?>>();

            return LabeledAppTextField(
              label: t.quiz.steps.date_of_birth.select_date_label,
              field: DateInputField(
                initialDate: dateData.dateTime,
                errorText: dateData.error,
                onDateSelected: cubit.onChanged,
              ),
            );
          },
        ),

        SecondaryButton(text: t.common.save_changes_button),
      ],
    );
  }
}
