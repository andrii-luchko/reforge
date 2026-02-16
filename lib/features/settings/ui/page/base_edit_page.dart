import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/shared/default_sliver_app_bar.dart';
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
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              DefaultSliverAppBar(
                onPressed: () => Navigator.of(context).pop(),
                title: title,
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 16)),
              SliverPadding(
                padding: DefaultSliverAppBar.horizontalPadding,
                sliver: body,
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
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
