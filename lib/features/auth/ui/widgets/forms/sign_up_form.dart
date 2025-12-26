import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_providers_buttons.dart';
import 'package:reforge/features/auth/ui/widgets/auth_redirect_text.dart';
import 'package:reforge/features/auth/ui/widgets/auth_title.dart';
import 'package:reforge/features/auth/ui/widgets/terms_check_box.dart';
import 'package:reforge/generated/i18n/strings.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/titled_divider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> onSignUpPressed() async {
    await context.read<AuthCubit>().signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthValidationCubit>();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.13,
          ),

          AuthTitle(
            title: t.create_acc.title,
            subtitle: t.create_acc.subtitle,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: BlocSelector<AuthValidationCubit, AuthValidationState, String?>(
              selector: (state) => state.emailError,
              builder: (context, emailError) {
                return LabeledAppTextField(
                  label: t.email_label,
                  field: AppTextField(
                    errorText: emailError,
                    hintText: t.email_hint,
                    controller: _emailController,
                    onChanged: cubit.emailChanged,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: BlocSelector<AuthValidationCubit, AuthValidationState, String?>(
              selector: (state) => state.passwordError,
              builder: (context, passwordError) {
                return LabeledAppTextField(
                  label: t.password_label,
                  field: AppTextField.password(
                    errorText: passwordError,
                    hintText: t.password_hint,
                    controller: _passwordController,
                    onChanged: cubit.passwordChanged,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: BlocSelector<AuthValidationCubit, AuthValidationState, String?>(
              selector: (state) => state.confirmPasswordError,
              builder: (context, confirmPasswordError) {
                return LabeledAppTextField(
                  label: t.confirm_password_label,
                  field: AppTextField.password(
                    errorText: confirmPasswordError,
                    hintText: t.confirm_password_hint,
                    controller: _confirmPasswordController,
                    onChanged: cubit.confirmPasswordChanged,
                  ),
                );
              },
            ),
          ),

          BlocSelector<AuthValidationCubit, AuthValidationState, bool>(
            selector: (state) => state.termsAccepted,
            builder: (context, termsAccepted) {
              return TermsConfirmationCheckBox(
                onChanged: cubit.termsAcceptanceChanged,
                value: termsAccepted,
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: BlocSelector<AuthValidationCubit, AuthValidationState, bool>(
              selector: (state) => state.canSubmit,
              builder: (context, canSubmit) {
                return PrimaryButton(
                  text: t.create_acc.submit_button,
                  onPressed: canSubmit ? onSignUpPressed : null,
                );
              },
            ),
          ),

          AuthRedirectText(
            part1: t.create_acc.footer_text_part1,
            part2: t.create_acc.footer_text_part2,
            onTap: () => const SignInPageRoute().go(context),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: TitledDivider(
              title: t.create_acc.divider_text,
            ),
          ),

          const Padding(padding: EdgeInsets.only(top: 32), child: AuthProvidersButtons()),
        ],
      ),
    );
  }
}
