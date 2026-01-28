import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
part 'timer_state.dart';
part 'timer_cubit.freezed.dart';

@injectable
class TimerCubit extends Cubit<TimerState> {
  TimerCubit() : super(const TimerState());

  Timer? _timer;

  void startTimer() {
    if (state.isRunning) return;

    emit(state.copyWith(isRunning: true));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(duration: state.duration + 1));
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void stopTimer() {
    _timer?.cancel();
    emit(const TimerState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
