import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/di/service_injector.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  const environment = kDebugMode ? Environment.dev : Environment.prod;

  getIt.init(environment: environment);
}
