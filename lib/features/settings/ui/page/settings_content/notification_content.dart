import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/notifications/controller/notification_permission_cubit.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/features/settings/ui/widgets/notification_switcher.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SettingsNotificationPage extends StatelessWidget {
  const SettingsNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsEditPage(
      title: WorkoutSettings.notification.title(t),
      body: const NotificationContent(),
    );
  }
}

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationPermissionCubit>().checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationPermissionCubit, NotificationPermissionState>(
      builder: (context, notificationState) {
        return notificationState.when(
          checking: () => const _NotificationContentSkeleton(),
          permissionNotDetermined: () => _NotificationTogglesContent(
            togglesEnabled: false,
            showPermissionBanner: true,
            onOpenSettings: () async {
              await context.read<NotificationPermissionCubit>().requestPermission();
              if (context.mounted) {
                await context.read<NotificationPermissionCubit>().checkPermission();
              }
            },
          ),
          permissionDenied: () => _NotificationTogglesContent(
            togglesEnabled: false,
            showPermissionBanner: true,
            onOpenSettings: () async {
              await AppSettings.openAppSettings();
              if (context.mounted) {
                await context.read<NotificationPermissionCubit>().checkPermission();
              }
            },
          ),
          permissionGranted: (token, isRequestingPermission) =>
              const _NotificationTogglesContent(
            togglesEnabled: true,
          ),
        );
      },
    );
  }
}

class _NotificationContentSkeleton extends StatelessWidget {
  const _NotificationContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            spacing: 12,
            children: [
              _SkeletonSwitcher(),
              _SkeletonSwitcher(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.appTheme.beige900,
        border: Border.all(color: context.appTheme.strokeCard),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _NotificationTogglesContent extends StatelessWidget {
  const _NotificationTogglesContent({
    required this.togglesEnabled,
    this.showPermissionBanner = false,
    this.onOpenSettings,
  });

  final bool togglesEnabled;
  final bool showPermissionBanner;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            spacing: 12,
            children: [
              if (showPermissionBanner && onOpenSettings != null)
                _PermissionDeniedBanner(onOpenSettings: onOpenSettings!),
              BlocBuilder<UserCubit, UserState>(
                builder: (context, userState) {
                  final user = userState.maybeWhen(
                    loaded: (u) => u is OnboardedUser ? u : null,
                    orElse: () => null,
                  );
                  return Column(
                    spacing: 12,
                    children: [
                      NotificationSwitcher(
                        title: t.settings.reminders,
                        value: user?.remindersEnabled ?? false,
                        enabled: togglesEnabled,
                        onChanged: togglesEnabled ? (value) => _onRemindersChanged(context, value) : null,
                      ),
                      NotificationSwitcher(
                        title: t.settings.announcements,
                        value: user?.announcementsEnabled ?? false,
                        enabled: togglesEnabled,
                        onChanged: togglesEnabled ? (value) => _onAnnouncementsChanged(context, value) : null,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onRemindersChanged(BuildContext context, bool value) async {
    await context.read<UserCubit>().updateProfile(
      PatchProfileRequest(remindersEnabled: value),
    );
  }

  Future<void> _onAnnouncementsChanged(BuildContext context, bool value) async {
    await context.read<UserCubit>().updateProfile(
      PatchProfileRequest(announcementsEnabled: value),
    );
  }
}

class _PermissionDeniedBanner extends StatelessWidget {
  const _PermissionDeniedBanner({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appTheme.beige900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appTheme.strokeCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.settings.notificationsDisabled,
            style: subheadH3Medium.copyWith(color: context.appTheme.beige100),
          ),
          const SizedBox(height: 8),
          Text(
            t.settings.enableNotificationsHint,
            style: bodyLRegular.copyWith(color: context.appTheme.beige300),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onOpenSettings,
            child: Text(t.settings.openSettings),
          ),
        ],
      ),
    );
  }
}
