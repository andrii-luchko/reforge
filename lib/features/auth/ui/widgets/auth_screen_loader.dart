import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class AuthScreenLoader extends StatelessWidget {
  const AuthScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, bool>(
      selector: (state) {
        return state.maybeMap(
          loading: (_) => true,
          orElse: () => false,
        );
      },
      builder: (context, selectedState) {
        if (!selectedState) return const SizedBox.shrink();

        return const Center(child: ScreenLoadingIndicator());
      },
    );
  }
}
