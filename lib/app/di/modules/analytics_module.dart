import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AnalyticsModule {
  @preResolve
  Future<FirebaseAnalytics> get firebaseAnalytics async {
    return FirebaseAnalytics.instance;
  }

  @preResolve
  Future<FirebaseCrashlytics> get firebaseCrashlytics async {
    final instance = FirebaseCrashlytics.instance;

    FlutterError.onError = instance.recordFlutterFatalError;

    return instance;
  }
}
