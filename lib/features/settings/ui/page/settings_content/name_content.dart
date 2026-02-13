import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/name_validator.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class NamePage extends StatelessWidget {
  const NamePage({required this.name, super.key});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();

    return BlocProvider(
      create: (context) => GenericValidationCubit<String?>(
        initialValue: name,
        validator: NameValidator.validate,
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<String?>(
        child: BaseSettingsEditPage(
          title: ProfileSettings.name.title(t),
          body: const NameContent(),
        ),
      ),
    );
  }

  Future<void> onSave(String? value, UserCubit cubit) async {
    final result = await cubit.updateProfile(
      PatchProfileRequest(username: value),
    );
    if (result case ErrorR(error: final e)) {
      throw e;
    }
  }
}

class NameContent extends StatelessWidget {
  const NameContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenericValidationCubit<String?>>();
    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        BlocSelector<GenericValidationCubit<String?>, GenericValidationState<String?>, ({String? name, String? error})>(
          selector: (state) {
            final error = state is GenericValidationError ? state.error : null;
            return (name: state.value, error: error);
          },
          builder: (context, value) {
            return LabeledAppTextField(
              label: t.settings.name,
              field: AppTextField(
                initialValue: value.name,
                hintText: t.settings.name,
                errorText: value.error,
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
