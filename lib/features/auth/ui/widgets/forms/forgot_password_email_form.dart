import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';
import 'package:reforge/features/auth/ui/widgets/auth_title.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/fields/app_text_field.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';

class ForgotPasswordEmailForm extends StatefulWidget {
  const ForgotPasswordEmailForm({super.key});

  @override
  State<ForgotPasswordEmailForm> createState() => _ForgotPasswordEmailFormState();
}

class _ForgotPasswordEmailFormState extends State<ForgotPasswordEmailForm> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        AuthTitle(
          title: t.forgot_password.title,
          subtitle: t.forgot_password.subtitle,
        ),

        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: BlocSelector<ForgotPasswordCubit, ForgotPasswordState, String?>(
            selector: (state) => state.emailError,
            builder: (context, emailError) {
              return LabeledAppTextField(
                label: t.common.email_label,
                field: AppTextfield(
                  hintText: t.common.email_hint,
                  errorText: emailError,
                  controller: _emailController,
                  onChanged: cubit.emailChanged,
                ),
              );
            },
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
            selector: (state) => state.canSubmit,
            builder: (context, canSubmit) {
              return PrimaryButton(
                text: t.forgot_password.submit_button,
                onPressed: canSubmit
                    ? () async {
                        // Handle

                        // ignore: inference_failure_on_function_invocation
                        await ResetSendPageRoute(email: cubit.state.email).push(context);
                      }
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
