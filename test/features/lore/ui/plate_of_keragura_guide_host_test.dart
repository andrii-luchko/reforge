import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/ui/guides/plate_of_keragura_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/ui/guide/lore_page_guide_scope.dart';
import 'package:reforge/features/lore/ui/guide/plate_of_keragura_guide_host.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

class _MockLoreCubit extends MockCubit<LoreState> implements LoreCubit {}

class _MockUserCubit extends MockCubit<UserState> implements UserCubit {}

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  final Set<(int, GuideId)> completed = {};

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    return completed.contains((userId, guideId));
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    completed.add((userId, guideId));
  }
}

final _user = OnboardedUser(
  id: 71,
  email: 'guide@example.com',
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990, 1, 15),
  workoutsPerWeek: 3,
  userName: 'Guide Tester',
  bodyWeight: 75,
);

PlatesEntity _plate({
  required int id,
  required bool isLocked,
}) {
  return PlatesEntity(
    id: id,
    name: isLocked ? 'Locked Plate' : 'Open Plate',
    title: 'A story',
    imageUrl: null,
    loreBody: null,
    unlockLevel: isLocked ? 10 : 1,
    isLocked: isLocked,
  );
}

Widget _target({
  required PlateOfKeraguraGuide guide,
  required PlateOfKeraguraGuideStep step,
}) {
  return GuideTarget(
    anchor: guide.anchor(step),
    scope: lorePageGuideScope,
    tooltip: guide.tooltip(step),
    child: SizedBox(
      width: 240,
      height: 72,
      child: Text(step.name),
    ),
  );
}

void main() {
  initTestTranslations();

  late _MockLoreCubit loreCubit;
  late _MockUserCubit userCubit;
  late StreamController<LoreState> loreStates;
  late StreamController<UserState> userStates;
  late ValueNotifier<Set<PlateOfKeraguraGuideStep>> renderedTargets;
  late LoreState currentLoreState;
  late UserState currentUserState;
  GuideState? guideState;

  setUp(() async {
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
    di.getIt.registerSingleton<GuideProgressRepository>(
      _MemoryGuideProgressRepository(),
    );

    loreCubit = _MockLoreCubit();
    userCubit = _MockUserCubit();
    loreStates = StreamController<LoreState>.broadcast();
    userStates = StreamController<UserState>.broadcast();
    renderedTargets = ValueNotifier({
      PlateOfKeraguraGuideStep.intro,
    });
    currentLoreState = LoreState(
      items: [_plate(id: 1, isLocked: false)],
    );
    currentUserState = UserState.loaded(_user);
    guideState = null;

    whenListen(
      loreCubit,
      loreStates.stream,
      initialState: currentLoreState,
    );
    whenListen(
      userCubit,
      userStates.stream,
      initialState: currentUserState,
    );
  });

  tearDown(() async {
    renderedTargets.dispose();
    await loreStates.close();
    await userStates.close();
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
  });

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LoreCubit>.value(value: loreCubit),
            BlocProvider<UserCubit>.value(value: userCubit),
          ],
          child: PlateOfKeraguraGuideHost(
            builder: (context, guide, state) {
              guideState = state;

              return Scaffold(
                body: ValueListenableBuilder<Set<PlateOfKeraguraGuideStep>>(
                  valueListenable: renderedTargets,
                  builder: (context, targets, _) {
                    return Column(
                      children: [
                        for (final step in PlateOfKeraguraGuideStep.values)
                          if (targets.contains(step))
                            _target(
                              guide: guide,
                              step: step,
                            ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> disposeHost(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('retries when an expected target appears on a later frame', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();
    expect(guideState, const GuideState.initial());

    renderedTargets.value = {
      PlateOfKeraguraGuideStep.intro,
      PlateOfKeraguraGuideStep.unlockedPlate,
    };
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.plateOfKeragura,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    expect(
      find.text(t.guides.plateOfKeragura.introTitle),
      findsOneWidget,
    );

    await disposeHost(tester);
  });

  testWidgets('starts a two-step session when locked data is absent', (
    tester,
  ) async {
    renderedTargets.value = {
      PlateOfKeraguraGuideStep.intro,
      PlateOfKeraguraGuideStep.unlockedPlate,
    };

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.plateOfKeragura,
        currentStep: 1,
        totalSteps: 2,
      ),
    );

    await disposeHost(tester);
  });

  testWidgets('falls back to the rendered two-step session after five retries', (
    tester,
  ) async {
    currentLoreState = LoreState(
      items: [
        _plate(id: 1, isLocked: false),
        _plate(id: 2, isLocked: true),
      ],
    );
    whenListen(
      loreCubit,
      loreStates.stream,
      initialState: currentLoreState,
    );
    renderedTargets.value = {
      PlateOfKeraguraGuideStep.intro,
      PlateOfKeraguraGuideStep.unlockedPlate,
    };

    await pumpHost(tester);
    for (var frame = 0; frame < 7; frame++) {
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.plateOfKeragura,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    expect(
      find.text(t.guides.plateOfKeragura.introTitle),
      findsOneWidget,
    );

    await disposeHost(tester);
  });

  testWidgets('new loading state cancels a stale retry chain', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();

    currentLoreState = currentLoreState.copyWith(isLoading: true);
    loreStates.add(currentLoreState);
    await tester.pump();

    renderedTargets.value = {
      PlateOfKeraguraGuideStep.intro,
      PlateOfKeraguraGuideStep.unlockedPlate,
    };
    for (var frame = 0; frame < 7; frame++) {
      await tester.pump();
    }

    expect(guideState, const GuideState.initial());
    expect(
      find.text(t.guides.plateOfKeragura.introTitle),
      findsNothing,
    );

    await disposeHost(tester);
  });

  testWidgets('does not start without an eligible user', (tester) async {
    currentUserState = const UserState.initial();
    whenListen(
      userCubit,
      userStates.stream,
      initialState: currentUserState,
    );
    renderedTargets.value = {
      PlateOfKeraguraGuideStep.intro,
      PlateOfKeraguraGuideStep.unlockedPlate,
    };

    await pumpHost(tester);
    for (var frame = 0; frame < 7; frame++) {
      await tester.pump();
    }

    expect(guideState, const GuideState.initial());
    expect(
      find.text(t.guides.plateOfKeragura.introTitle),
      findsNothing,
    );

    await disposeHost(tester);
  });

  testWidgets('disposing the host cancels scheduled retries', (tester) async {
    await pumpHost(tester);
    await tester.pump();

    await disposeHost(tester);
    for (var frame = 0; frame < 7; frame++) {
      await tester.pump();
    }

    expect(tester.takeException(), isNull);
  });
}
