import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'rest_timer_state.dart';
part 'rest_timer_cubit.freezed.dart';

const int adjustValue = 15;
const int defaultRestDuration = 90;

@injectable
class RestTimerCubit extends Cubit<RestTimerState> {
  RestTimerCubit() : super(const RestTimerState());

  Timer? _timer;

  double get progress => state.remainingSeconds / state.targetSeconds;

  void initTimer(int seconds) {
    emit(
      state.copyWith(
        remainingSeconds: seconds,
        targetSeconds: seconds,
        elapsedSeconds: 0,
        isRunning: false,
      ),
    );
  }

  void startTimer() {
    if (state.isRunning) return;

    emit(state.copyWith(isRunning: true));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = state.remainingSeconds - 1;

      final newElapsed = state.elapsedSeconds + 1;

      emit(
        state.copyWith(
          remainingSeconds: newRemaining,
          elapsedSeconds: newElapsed,
        ),
      );
    });
  }

  void adjustTime(int seconds) {
    // We only change the “deadline”.
    // We don't touch elapsedSeconds, because you can't turn back time :)

    emit(
      state.copyWith(
        remainingSeconds: state.remainingSeconds + seconds,
        targetSeconds: state.targetSeconds + seconds,
      ),
    );
  }

  int stopTimerAndGetResult() {
    _timer?.cancel();
    final totalTimeSpent = state.elapsedSeconds;
    emit(const RestTimerState());
    return totalTimeSpent;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
