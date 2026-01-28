import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RouterModule {
  @lazySingleton
  RouteObserver<ModalRoute<void>> get routeObserver => RouteObserver<ModalRoute<void>>();
}
