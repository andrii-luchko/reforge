import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';

import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:toastification/toastification.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) async {
        await state.maybeWhen(
          initial: () async {
            await context.read<AuthCubit>().signOut();
          },
          error: (message) {
            toastification.showErrorToast(message, context);
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: .end,
            spacing: 16,
            children: [
              SecondaryButton(
                text: 'Delete account',
                onPressed: () async {
                  final userCubit = context.read<UserCubit>();
                  await userCubit.deleteUser();
                },
              ),
              PrimaryButton(
                text: 'Logout',
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
