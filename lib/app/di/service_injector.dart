import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/di/modules/background_handler.dart';
import 'package:reforge/app/di/service_injector.config.dart';
import 'package:reforge/features/notifications/data/service/fcm_notification_service.dart';
import 'package:reforge/firebase_options.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  const environment = kDebugMode ? Environment.dev : Environment.prod;

  await initializeRevenueCat();

  await getIt.init(environment: environment);

  getIt<FcmNotificationService>();
}

Future<void> initializeRevenueCat() async {
  //TODO(Masayoshi): Change to real configuration
  const androidApiKey = Env.revenuecatApiKeyGoogle;
  const iosApiKey = Env.revenuecatApiKeyTest;

  if (androidApiKey == '' || iosApiKey == '') throw Exception('One of the revenucats api keys are null');

  final config = PurchasesConfiguration(
    switch (Platform.operatingSystem) {
      'ios' => iosApiKey,
      'android' => androidApiKey,
      _ => throw UnimplementedError(),
    },
  );

  await Purchases.configure(config);
}
