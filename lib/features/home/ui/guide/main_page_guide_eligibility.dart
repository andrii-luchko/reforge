import 'package:reforge/features/home/controller/cubit/home_cubit.dart';

bool canStartMainPageGuide(HomeState state) {
  return !state.isLoading && state.user != null && state.currentStats != null && state.rank?.lvl != null;
}
