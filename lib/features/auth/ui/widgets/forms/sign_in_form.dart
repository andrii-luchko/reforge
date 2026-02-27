import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';

import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/features/auth/controllers/validation/auth_validation_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_providers_buttons.dart';
import 'package:reforge/features/auth/ui/widgets/auth_redirect_text.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';

import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/titled_divider.dart';
import 'package:toastification/toastification.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthValidationCubit>();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeMap(
          error: (state) => toastification.showErrorToast(state.message, context),
          // ignore: no_empty_block
          orElse: () {},
        );
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.13,
            ),
            CenteredTitleSection(
              title: t.signin.title,
              subtitle: t.signin.subtitle,
            ),

            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: BlocSelector<AuthValidationCubit, AuthValidationState, String?>(
                selector: (state) => state.emailError,
                builder: (context, emailError) {
                  return LabeledAppTextField(
                    label: t.common.email_label,
                    field: AppTextField(
                      errorText: emailError,
                      hintText: t.common.email_hint,
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

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ThirtyButton(
                  text: t.signin.forgot_password_button,
                  // ignore: inference_failure_on_function_invocation
                  onPressed: () => const ForgotPasswordEmailPageRoute().push(context),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 56),
              child: BlocSelector<AuthValidationCubit, AuthValidationState, bool>(
                selector: (state) => state.canSubmit,
                builder: (context, canSubmit) {
                  return PrimaryButton(
                    text: t.signin.submit_button,
                    onPressed: canSubmit
                        ? () async {
                            await context.read<AuthCubit>().signIn(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
            AuthRedirectText(
              part1: t.signin.footer_text_part1,
              part2: t.signin.footer_text_part2,

              onTap: () => const SignUpPageRoute().go(context),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: TitledDivider(
                title: t.signin.divider_text,
              ),
            ),

            const Padding(padding: EdgeInsets.only(top: 32), child: AuthProvidersButtons()),
          ],
        ),
      ),
    );
  }
}
