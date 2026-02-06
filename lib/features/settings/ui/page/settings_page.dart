import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/photo/service/image_pi%D1%81ker_service.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/helpers/settings_navigation.dart';
import 'package:reforge/features/settings/ui/widgets/settings_image_piker.dart';
import 'package:reforge/features/settings/ui/widgets/settings_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/two_options_dialog_template.dart';

import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) async {
        await state.maybeWhen(
          initial: () async {
            await context.read<AuthCubit>().signOut();
          },
          error: (message) {
            toastification.showErrorToast(message, context);
          },
          // ignore: no_empty_block
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DefaultBackground(
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverAppBar(
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: false,
                    title: Skeleton.keep(
                      child: Text(
                        'Profile info',
                        style: subheadH1Medium.copyWith(color: appTheme.beige100),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: ProfileSettings.values.length,
                    itemBuilder: (context, index) {
                      final setting = ProfileSettings.values[index];

                      if (setting == .image) {
                        return Align(
                          child: SettingsImagePicker(
                            onPressed: () async {
                              // ignore: unused_local_variable
                              final file = await ImagePickerService.pickAndCrop(context);
                            },
                          ),
                        );
                      }

                      return SettingTile(
                        assetPath: setting.icon,
                        title: setting.title(t),
                        text: 'Some value',
                        onPressed: () async {
                          SettingsNavigation.open(context, setting);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
                ),
                const SliverPadding(padding: .only(bottom: 32)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Settings',
                      style: subheadH2Medium.copyWith(color: appTheme.beige100),
                    ),
                  ),
                ),
                const SliverPadding(padding: .only(bottom: 16)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: WorkoutSettings.values.length,
                    itemBuilder: (context, index) {
                      final setting = WorkoutSettings.values[index];

                      return SettingTile(
                        assetPath: setting.icon,
                        title: setting.title(t),
                        text: 'Some value',
                        onPressed: () async {
                          SettingsNavigation.open(context, setting);
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
                ),
                const SliverPadding(padding: .only(bottom: 32)),
                SliverPadding(
                  padding: const .symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: PrimaryButton(
                      text: 'Logout',
                      onPressed: () async {
                        final logout =
                            await confirmAction(
                              context,
                              title: 'Log out',
                              message: 'Are you sure you want to log out?',
                            ) ??
                            false;

                        if (logout && context.mounted) {
                          await context.read<AuthCubit>().signOut();
                        }
                      },
                    ),
                  ),
                ),
                const SliverPadding(padding: .only(bottom: 16)),
                SliverPadding(
                  padding: const .symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: SecondaryButton(
                      text: 'Delete account',
                      onPressed: () async {
                        final delete =
                            await confirmAction(
                              context,
                              title: 'Delete account',
                              message: 'Do you really want to delete?\nThis action cannot be undone',
                            ) ??
                            false;

                        if (delete && context.mounted) {
                          final userCubit = context.read<UserCubit>();
                          await userCubit.deleteUser();
                        }
                      },
                    ),
                  ),
                ),

                SliverPadding(padding: EdgeInsets.only(bottom: context.appTheme.sliverBottomSpacing / 4)),
              ],
            ),
          ),

          additionalAnimationsBehind: [
            Positioned.fill(child: SunRaysShaderWidget.fromTop(color: appTheme.orange500)),
            const ParticlesWidget(),
          ],
        ),
      ),
    );
  }

  static Future<bool?> confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return AppDialog.show<bool?>(
      context,
      child: TwoOptionsDialog(
        title: title,
        rightButtonLabel: t.common.confirm_button,
        leftButtonLabel: t.common.back_button,
        contentBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
        ),
      ),
    );
  }
}
