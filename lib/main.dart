import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/auth/controllers/forgot_password/forgot_password_cubit.dart';
import 'package:reforge/features/calendar/controllers/calendar/calendar_cubit.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/notifications/controller/notification_feed_cubit.dart';
import 'package:reforge/features/notifications/controller/notification_permission_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:toastification/toastification.dart';

void main() async {
  await runZonedGuarded(
    () async {
      final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();

      await LocaleSettings.useDeviceLocale();
      await di.configureDependencies();

      runApp(
        ToastificationWrapper(
          config: const ToastificationConfig(
            maxToastLimit: 3,
          ),
          child: TranslationProvider(
            child: const App(),
          ),
        ),
      );

      binding.allowFirstFrame();
    },
    (error, stackTrace) async {
      final crashlytics = di.getIt<FirebaseCrashlytics>();
      await crashlytics.recordError(error, stackTrace, fatal: true);
      logger.e('Unexpected error', error, stackTrace);
    },
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<AuthCubit>(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => di.getIt<UserCubit>(),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => di.getIt<ForgotPasswordCubit>(),
        ),
        BlocProvider(
          create: (_) => di.getIt<AchievementsCubit>(),
        ),
        BlocProvider(create: (_) => di.getIt<NotificationFeedCubit>()),
        BlocProvider(
          create: (_) => di.getIt<NotificationPermissionCubit>(),
          lazy: false,
        ),

        BlocProvider(create: (_) => di.getIt<HomeCubit>()),

        BlocProvider(create: (_) => di.getIt<CalendarCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppLocaleUtils.supportedLocales,
        locale: TranslationProvider.of(context).flutterLocale,
        theme: ThemeDataValues.lightThemeData,
        darkTheme: ThemeDataValues.darkThemeData,
        themeMode: ThemeMode.dark,
        builder: (_, child) => Portal(child: child ?? ErrorWidget('MaterialApp.router child is null')),
      ),
    );
  }
}
