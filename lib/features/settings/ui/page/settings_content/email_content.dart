import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class EmailPage extends StatelessWidget {
  const EmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenericValidationCubit<String?>(
        initialValue: null,
        validator: validateEmail,
        onSave: (_) async {},
      ),
      child: GenericSaveListener<String?>(
        child: BaseSettingsEditPage(title: ProfileSettings.email.title(t), body: const EmailContent()),
      ),
    );
  }
}

class EmailContent extends StatelessWidget {
  const EmailContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenericValidationCubit<String?>>();
    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<
          GenericValidationCubit<String?>,
          GenericValidationState<String?>,
          ({String? email, String? error})
        >(
          selector: (state) {
            final error = state is GenericValidationError ? state.error : null;
            return (email: state.value, error: error);
          },
          builder: (context, value) {
            return LabeledAppTextField(
              label: t.common.email_label,
              field: AppTextField(
                initialValue: value.email,
                errorText: value.error,
                hintText: t.common.email_hint,

                onChanged: cubit.onChanged,
              ),
            );
          },
        ),

        SecondaryButton(
          text: t.common.save_changes_button,
          onPressed: cubit.save,
        ),
      ],
    );
  }
}
