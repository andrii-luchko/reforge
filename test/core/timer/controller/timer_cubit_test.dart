// ignore_for_file: discarded_futures

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';

void main() {
  group('TimerCubit', () {
    test('startTimer when not running sets isRunning to true', () {
      final cubit = TimerCubit();
      expect(cubit.state.isRunning, false);

      cubit.startTimer();

      expect(cubit.state.isRunning, true);
      cubit.close();
    });

    test('startTimer when already running does nothing', () {
      final cubit = TimerCubit()..startTimer();
      final stateAfterFirstStart = cubit.state;

      cubit.startTimer();

      expect(cubit.state, stateAfterFirstStart);
      cubit.close();
    });

    test('pauseTimer sets isRunning to false', () {
      final cubit = TimerCubit()..startTimer();
      expect(cubit.state.isRunning, true);

      cubit.pauseTimer();

      expect(cubit.state.isRunning, false);
      cubit.close();
    });

    test('stopTimer resets state', () {
      final cubit = TimerCubit()
        ..startTimer()
        ..stopTimer();

      expect(cubit.state.duration, 0);
      expect(cubit.state.isRunning, false);
      cubit.close();
    });

    test('startTimer increments duration every second', () {
      FakeAsync().run((fakeAsync) {
        final cubit = TimerCubit()..startTimer();

        expect(cubit.state.isRunning, true);
        expect(cubit.state.duration, 0);

        fakeAsync.elapse(const Duration(seconds: 1));
        expect(cubit.state.duration, 1);

        fakeAsync.elapse(const Duration(seconds: 2));
        expect(cubit.state.duration, 3);

        cubit.close();
      });
    });
  });
}
