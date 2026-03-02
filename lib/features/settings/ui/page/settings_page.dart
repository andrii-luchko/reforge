import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/launch_url_recognizer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/photo/enum/picker_option.dart';
import 'package:reforge/core/photo/service/image_picker_service.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/settings/data/services/system_info_services.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/widgets/no_subscription_widget.dart';
import 'package:reforge/features/settings/ui/widgets/settings_image_piker.dart';
import 'package:reforge/features/settings/ui/widgets/settings_tile.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.settingsView));
  }

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
            child: Skeletonizer(
              enabled: context.watch<UserCubit>().state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
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
                          t.settings.profileInfo,
                          style: subheadH1Medium.copyWith(color: appTheme.beige100),
                        ),
                      ),
                    ),
                  ),

                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      return state.maybeMap(
                        loaded: (value) {
                          final user = value.user;

                          return user.map(
                            newUser: (user) => const SettingsNewUserWidget(),
                            onboarded: (onboarded) => SettingsGroup(user: onboarded),
                          );
                        },
                        updating: (value) {
                          final user = value.user;

                          return user.map(
                            newUser: (user) => const SettingsNewUserWidget(),
                            onboarded: (onboarded) => SettingsGroup(user: onboarded),
                          );
                        },

                        orElse: () {
                          return const SettingsNewUserWidget();
                        },
                      );
                    },
                  ),
                  SliverPadding(
                    padding: const .symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: PrimaryButton(
                        text: t.settings.logout,
                        onPressed: () async {
                          unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.settingsLogoutClick));
                          final logout =
                              await confirmAction(
                                context,
                                title: t.settings.logoutTitle,
                                message: t.settings.logoutMessage,
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
                        text: t.settings.deleteAccount,
                        onPressed: () async {
                          unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.settingsDeleteAccountClick));
                          final delete =
                              await confirmAction(
                                context,
                                title: t.settings.deleteAccount,
                                message: t.settings.deleteAccountMessage,
                              ) ??
                              false;

                          if (delete && context.mounted) {
                            final userCubit = context.read<UserCubit>();
                            await userCubit.deleteUserById();

                            if (context.mounted) {
                              await context.read<AuthCubit>().signOut();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  SliverPadding(padding: EdgeInsets.only(bottom: context.appTheme.sliverBottomSpacing / 4)),
                ],
              ),
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

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.user,
    super.key,
  });

  final OnboardedUser user;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final userCubit = context.read<UserCubit>();
    final subscription = context.watch<SubscriptionCubit>().state.currentSubscription;
    logger.d(subscription ?? '');

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: ProfileSettings.values.length,
            itemBuilder: (context, index) {
              final setting = ProfileSettings.values[index];

              if (setting == .image) {
                return Align(
                  child: SettingsImagePicker(
                    imageUrl: user.avatarUrl,
                    onPressed: () async {
                      final pickedData = await ImagePickerService.pickAndCrop(context);
                      if (pickedData == null) return;

                      logger.d(
                        'picker option: ${pickedData.option}, hasFile: ${pickedData.file != null}',
                      );

                      if (pickedData.option == PickerOption.deletePhoto) {
                        await userCubit.deleteUserAvatar();
                        return;
                      }

                      final file = pickedData.file;
                      if (file != null) {
                        return userCubit.uploadUserAvatar(file);
                      }
                    },
                  ),
                );
              }

              return SettingTile(
                assetPath: setting.icon,
                title: setting.title(t),
                text: setting.getDisplayValue(
                  user,
                  t,
                ),
                onPressed: () async {
                  if (setting.route != null) {
                    setting.push(context);
                  }
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
        const SliverPadding(padding: .only(bottom: 32)),

        if (subscription == null) const NoSubscriptionWidget(),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              t.settings.settings,
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
              if (setting == WorkoutSettings.subscription && subscription == null) {
                return const SizedBox.shrink();
              }

              return SettingTile(
                assetPath: setting.icon,
                title: setting.title(t),
                text: setting.getDisplayValue(user, t, subscription),
                onPressed: () async {
                  if (setting == WorkoutSettings.privacy) {
                    unawaited(LaunchUrl.launchAppLink(Env.privacyPolicyUrl));
                  }
                  if (setting == WorkoutSettings.termsAndConditions) {
                    unawaited(LaunchUrl.launchAppLink(Env.termsOfUseUrl));
                  }
                  if (setting.route != null) {
                    setting.push(context);
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              final setting = WorkoutSettings.values[index];
              if (setting == WorkoutSettings.subscription && subscription == null) return const SizedBox.shrink();
              return const SizedBox(height: 12);
            },
          ),
        ),

        const SliverPadding(padding: .all(16), sliver: AppVersionWidget()),
        const SliverPadding(padding: .only(bottom: 32)),
      ],
    );
  }
}

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersion = di.getIt<SystemInfoServiceI>().appVersion;
    return SliverToBoxAdapter(
      child: Text(
        'App Version: $appVersion',
        textAlign: .center,
        style: subheadH5Medium.copyWith(color: context.appTheme.beige700),
      ),
    );
  }
}

class SettingsNewUserWidget extends StatelessWidget {
  const SettingsNewUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
      sliver: SliverToBoxAdapter(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            decoration: BoxDecoration(
              color: context.appTheme.beige900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appTheme.strokeCard),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: appTheme.red400),
                const SizedBox(height: 16),
                Text(t.settings.userEmpty, style: bodyLRegular),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
