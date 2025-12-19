import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/app_router.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

void main() async {
  await runZonedGuarded(
    () async {
      final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
      await LocaleSettings.useDeviceLocale();
      await di.configureDependencies();

      runApp(TranslationProvider(child: const App()));

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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      locale: TranslationProvider.of(context).flutterLocale,
      theme: ThemeDataValues.lightThemeData,
      darkTheme: ThemeDataValues.darkThemeData,
      themeMode: ThemeMode.dark,
      builder: (_, child) => child ?? ErrorWidget('MaterialApp.router child is null'),
    );
  }
}
