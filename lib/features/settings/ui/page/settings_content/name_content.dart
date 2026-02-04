import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/validators/name_validator.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class NamePage extends StatelessWidget {
  const NamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<String?>(
        initialValue: 'name',
        validator: NameValidator.validate,
        onSave: (_) async {},
      ),
      child: BaseSettingsEditPage(
        title: ProfileSettings.name.title(t),
        body: const NameContent(),
      ),
    );
  }
}

class NameContent extends StatelessWidget {
  const NameContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<GenericValidationCubit<String?>, GenericValidationState<String?>, ({String? name, String? error})>(
          selector: (state) {
            return (name: state.value, error: state.error);
          },
          builder: (context, value) {
            final cubit = context.read<GenericValidationCubit<String?>>();
            return LabeledAppTextField(
              label: 'Name',
              field: AppTextField(
                initialValue: value.name,
                hintText: 'Name',
                errorText: value.error,
                onChanged: cubit.onChanged,
              ),
            );
          },
        ),

        SecondaryButton(text: t.common.save_changes_button),
      ],
    );
  }
}
