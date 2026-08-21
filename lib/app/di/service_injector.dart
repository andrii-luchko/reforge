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
import 'package:reforge/features/exercise_session/data/repositories/test_exercise_session_repository.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/notifications/data/service/fcm_notification_service.dart';
import 'package:reforge/features/workout_program/data/repositories/test_workout_program_repository.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';
import 'package:reforge/features/workout_quiz/data/repositories/test_workout_quiz_repository.dart';
import 'package:reforge/features/workout_quiz/domain/repositories/workout_quiz_repository.dart';
import 'package:reforge/features/workout_session/data/repositories/test_workout_session_repository.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:reforge/firebase_options.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  const environment = kDebugMode ? Environment.dev : Environment.prod;
  await initializeRevenueCat();

  await getIt.init(environment: environment);

  //TODO(Masayoshi): Set to true to use mock/test repositories for the training session flow
  const useMockRepositories = bool.fromEnvironment('USE_MOCKS', defaultValue: true);

  if (useMockRepositories) {
    if (getIt.isRegistered<WorkoutProgramRepository>()) {
      await getIt.unregister<WorkoutProgramRepository>();
    }
    getIt.registerFactory<WorkoutProgramRepository>(
      () => const TestWorkoutProgramRepository(),
    );

    if (getIt.isRegistered<WorkoutSessionRepository>()) {
      await getIt.unregister<WorkoutSessionRepository>();
    }
    getIt.registerFactory<WorkoutSessionRepository>(
      () => const TestWorkoutSessionRepository(),
    );

    if (getIt.isRegistered<ExerciseSessionRepository>()) {
      await getIt.unregister<ExerciseSessionRepository>();
    }
    getIt.registerFactory<ExerciseSessionRepository>(
      () => const TestExerciseSessionRepository(),
    );

    if (getIt.isRegistered<WorkoutQuizRepository>()) {
      await getIt.unregister<WorkoutQuizRepository>();
    }

    getIt.registerFactory<WorkoutQuizRepository>(
      () => const TestWorkoutQuizRepository(),
    );
  }

  getIt<FcmNotificationService>();
}

Future<void> initializeRevenueCat() async {
  const androidApiKey = Env.revenuecatApiKeyGoogle;
  const iosApiKey = Env.revenuecatApiKeyApple;

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
