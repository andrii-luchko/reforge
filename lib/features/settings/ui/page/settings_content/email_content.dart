import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/email.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class EmailPage extends StatelessWidget {
  const EmailPage({required this.initialEmail, super.key});

  final String? initialEmail;
  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();

    return BlocProvider(
      create: (context) => GenericValidationCubit<String?>(
        initialValue: initialEmail,
        validator: validateEmail,
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<String?>(
        child: BaseSettingsEditPage(title: ProfileSettings.email.title(t), body: const EmailContent()),
      ),
    );
  }

  Future<void> onSave(String? value, UserCubit cubit) async {
    if (value == null) return;

    final result = await cubit.updateEmail(
      value,
    );
    if (result case ErrorR(error: final e)) {
      throw e;
    }
  }
}

class EmailContent extends StatelessWidget {
  const EmailContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenericValidationCubit<String?>>();
    return SliverMainAxisGroup(
      slivers: [
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
            return SliverToBoxAdapter(
              child: LabeledAppTextField(
                label: t.common.email_label,
                field: AppTextField(
                  initialValue: value.email,
                  errorText: value.error,
                  hintText: t.common.email_hint,
                  onChanged: cubit.onChanged,
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
