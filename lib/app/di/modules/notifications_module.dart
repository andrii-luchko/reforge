import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NotificationsModule {
  @preResolve
  @singleton
  Future<FirebaseMessaging> get firebaseMessaging async {
    final instance = FirebaseMessaging.instance;
    return instance;
  }
}
