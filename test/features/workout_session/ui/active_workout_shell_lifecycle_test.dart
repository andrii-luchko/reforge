import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/ui/active_workout/pages/active_workout_shell.dart';

import '../../../helpers/test_setup.dart';

class _MockWorkoutSessionFlowCubit extends MockCubit<WorkoutSessionFlowState> implements WorkoutSessionFlowCubit {}

class _MockUserCubit extends MockCubit<UserState> implements UserCubit {}

void main() {
  setUpAll(initTestTranslations);

  testWidgets('syncs cached workout duration on background and foreground', (
    tester,
  ) async {
    final flowCubit = _MockWorkoutSessionFlowCubit();
    final userCubit = _MockUserCubit();
    final timerCubit = TimerCubit();
    when(() => flowCubit.state).thenReturn(
      const WorkoutSessionFlowState(
        isRestoredSession: true,
        restoredDurationSec: 42,
      ),
    );
    when(() => userCubit.state).thenReturn(const UserState.initial());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutSessionFlowCubit>.value(value: flowCubit),
          BlocProvider<TimerCubit>.value(value: timerCubit),
          BlocProvider<UserCubit>.value(value: userCubit),
        ],
        child: MaterialApp(
          theme: ThemeDataValues.darkThemeData,
          home: const ActiveWorkoutShell(child: SizedBox.shrink()),
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await tester.pump();

    verify(() => flowCubit.syncDuration(42)).called(1);

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pump();

    verify(() => flowCubit.syncDuration(42)).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    await timerCubit.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
