import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';

class BaseSettingsEditPage extends StatelessWidget {
  const BaseSettingsEditPage({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppAppBar(
        actions: [
          Padding(
            padding: const .only(right: 16),
            child: Text(title, style: subheadH1Medium.copyWith(color: context.appTheme.beige100)),
          ),
        ],
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: DefaultBackground(
        body: SafeArea(
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(child: body),
              ],
            ),
          ),
        ),
        loader: const Positioned.fill(child: UserUpdatingLoader()),
      ),
    );
  }
}

class UserUpdatingLoader extends StatelessWidget {
  const UserUpdatingLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserCubit, UserState, bool>(
      selector: (state) => state is Updating,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
