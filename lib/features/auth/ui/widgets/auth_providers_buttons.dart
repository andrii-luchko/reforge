import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class AuthProvidersButtons extends StatelessWidget {
  const AuthProvidersButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconButton(
          iconAsset: Assets.images.icons.apple,
          onPressed: () async {
            await context.read<AuthCubit>().signWithApple();
          },
        ),
        const SizedBox(width: 12),
        AppIconButton(
          iconAsset: Assets.images.icons.google,
          onPressed: () async {
            await context.read<AuthCubit>().signWithGoogle();
          },
        ),
      ],
    );
  }
}
