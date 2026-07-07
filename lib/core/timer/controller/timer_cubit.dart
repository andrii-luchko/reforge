import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
part 'timer_state.dart';
part 'timer_cubit.freezed.dart';

@injectable
class TimerCubit extends Cubit<TimerState> {
  TimerCubit() : super(const TimerState());

  Timer? _timer;

  /// The wall-clock moment when the timer was last (re-)started.
  DateTime? _startedAt;

  /// Duration accumulated before the last pause, in seconds.
  int _baseSec = 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Starts counting from 0.
  void startTimer() {
    if (state.isRunning) return;
    _baseSec = 0;
    _startTicking();
  }

  /// Resumes or starts the timer from [initialSeconds].
  /// Used when restoring an interrupted workout session.
  void startTimerFrom(int initialSeconds) {
    _timer?.cancel();
    _baseSec = initialSeconds;
    _startTicking();
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _baseSec = state.duration; // snapshot elapsed before pausing
    _startedAt = null;
    emit(state.copyWith(isRunning: false));
  }

  /// Resets the timer to zero and stops it.
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
    _baseSec = 0;
    emit(const TimerState());
  }

  /// Resumes a paused timer without changing the accumulated duration.
  void resumeTimer() {
    if (state.isRunning) return;
    _startTicking();
  }

  /// Call this from [WidgetsBindingObserver.didChangeAppLifecycleState]
  /// when [AppLifecycleState.resumed] fires.
  ///
  /// Forces an immediate state update so the displayed time jumps to the
  /// correct value instead of waiting up to 1 second for the next tick.
  void onAppResumed() {
    if (!state.isRunning || _startedAt == null) return;
    _emitElapsed();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _startTicking() {
    _startedAt = DateTime.now();
    emit(
      state.copyWith(
        duration: _baseSec,
        isRunning: true,
      ),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _emitElapsed());
  }

  void _emitElapsed() {
    if (_startedAt == null) return;
    final elapsed = _baseSec + DateTime.now().difference(_startedAt!).inSeconds;
    emit(state.copyWith(duration: elapsed));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
