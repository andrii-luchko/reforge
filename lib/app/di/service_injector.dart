import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
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

  await getIt.init(environment: environment);

  getIt<FcmNotificationService>();
}
