import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/auth/controllers/forgot_password/reset_password_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_title.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class CreateNewPasswordForm extends StatefulWidget {
  const CreateNewPasswordForm({super.key});

  @override
  State<CreateNewPasswordForm> createState() => _CreateNewPasswordFormState();
}

class _CreateNewPasswordFormState extends State<CreateNewPasswordForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResetPasswordCubit>();

    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) async {
        if (state.isSuccess) {
          // ignore: inference_failure_on_function_invocation
          await const SuccessPasswordChangePageRoute().push(context);
        }
      },
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          AuthTitle(
            title: t.create_password.title,
            subtitle: t.create_password.subtitle,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: BlocSelector<ResetPasswordCubit, ResetPasswordState, String?>(
              selector: (state) => state.newPasswordError,
              builder: (context, passwordError) {
                return LabeledAppTextField(
                  label: t.common.password_label,
                  field: AppTextField.password(
                    errorText: passwordError,
                    hintText: t.common.password_hint,
                    controller: _passwordController,
                    onChanged: cubit.passwordChanged,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: BlocSelector<ResetPasswordCubit, ResetPasswordState, String?>(
              selector: (state) => state.confirmPasswordError,
              builder: (context, confirmPasswordError) {
                return LabeledAppTextField(
                  label: t.common.confirm_password_label,
                  field: AppTextField.password(
                    errorText: confirmPasswordError,
                    hintText: t.common.confirm_password_hint,
                    controller: _confirmPasswordController,
                    onChanged: cubit.confirmPasswordChanged,
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: BlocSelector<ResetPasswordCubit, ResetPasswordState, bool>(
              selector: (state) => state.isValid,
              builder: (context, canSubmit) {
                return PrimaryButton(
                  text: t.create_password.submit_button,
                  onPressed: canSubmit
                      ? () async {
                          await context.read<ResetPasswordCubit>().submit();
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
