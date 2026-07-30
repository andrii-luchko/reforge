import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/achievements/ui/guide/forge_attributes_guide_host.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

class _MockAchievementsCubit extends MockCubit<AchievementsState> implements AchievementsCubit {}

class _MockUserCubit extends MockCubit<UserState> implements UserCubit {}

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  final Set<(int, GuideId)> completed = {};
  final List<int> checkedUserIds = [];
  bool forceCompleted = false;

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    checkedUserIds.add(userId);
    return forceCompleted || completed.contains((userId, guideId));
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

AttributesEntity _attribute(ForgeAttribute attribute) {
  return AttributesEntity(
    attribute: attribute,
    totalXp: 100,
    currentXp: 10,
  );
}

Widget _target({
  required ForgeAttributesGuide guide,
  required ForgeAttributesGuideStep step,
}) {
  return GuideTarget(
    anchor: guide.anchor(step),
    scope: achievementsPageGuideScope,
    tooltip: guide.tooltip(step),
    child: SizedBox(
      width: 240,
      height: 64,
      child: Text(step.name),
    ),
  );
}

void main() {
  initTestTranslations();

  late _MockAchievementsCubit achievementsCubit;
  late _MockUserCubit userCubit;
  late StreamController<AchievementsState> achievementStates;
  late StreamController<UserState> userStates;
  late ValueNotifier<Set<ForgeAttributesGuideStep>> renderedTargets;
  late _MemoryGuideProgressRepository repository;
  late AchievementsState currentAchievementsState;
  GuideState? guideState;

  setUp(() async {
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
    repository = _MemoryGuideProgressRepository();
    di.getIt.registerSingleton<GuideProgressRepository>(repository);

    achievementsCubit = _MockAchievementsCubit();
    userCubit = _MockUserCubit();
    achievementStates = StreamController<AchievementsState>.broadcast();
    userStates = StreamController<UserState>.broadcast();
    renderedTargets = ValueNotifier({
      ForgeAttributesGuideStep.intro,
    });
    currentAchievementsState = AchievementsState(
      attributes: [_attribute(ForgeAttribute.kobo)],
    );
    guideState = null;

    whenListen(
      achievementsCubit,
      achievementStates.stream,
      initialState: currentAchievementsState,
    );
    whenListen(
      userCubit,
      userStates.stream,
      initialState: UserState.loaded(_user),
    );
  });

  tearDown(() async {
    renderedTargets.dispose();
    await achievementStates.close();
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
            BlocProvider<AchievementsCubit>.value(value: achievementsCubit),
            BlocProvider<UserCubit>.value(value: userCubit),
          ],
          child: ForgeAttributesGuideHost(
            child: Builder(
              builder: (context) {
                guideState = context.watch<GuideCubit>().state;
                final guide = context.read<ForgeAttributesGuide>();

                return Scaffold(
                  body: ValueListenableBuilder<Set<ForgeAttributesGuideStep>>(
                    valueListenable: renderedTargets,
                    builder: (context, targets, _) {
                      return Column(
                        children: [
                          for (final step in ForgeAttributesGuideStep.values)
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
      ),
    );
  }

  Future<void> disposeHost(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('retries when an attribute target appears on a later frame', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();
    expect(guideState, const GuideState.initial());

    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
    };
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.forgeAttributes,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    expect(
      find.text(t.guides.forgeAttributes.introTitle),
      findsOneWidget,
    );

    await disposeHost(tester);
  });

  testWidgets('starts a partial session despite an unrelated error', (
    tester,
  ) async {
    currentAchievementsState = AchievementsState(
      attributes: [
        _attribute(ForgeAttribute.kannuki),
        _attribute(ForgeAttribute.kobo),
      ],
      error: 'Badges unavailable',
    );
    whenListen(
      achievementsCubit,
      achievementStates.stream,
      initialState: currentAchievementsState,
    );
    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
      ForgeAttributesGuideStep.taga,
    };

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.forgeAttributes,
        currentStep: 1,
        totalSteps: 3,
      ),
    );

    await disposeHost(tester);
  });

  testWidgets('stops retrying after five notReady results', (tester) async {
    await pumpHost(tester);
    for (var frame = 0; frame < 7; frame++) {
      await tester.pump();
    }

    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
    };
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump();
    }

    expect(guideState, const GuideState.initial());

    await disposeHost(tester);
  });

  testWidgets('a new loading cycle cancels stale retries and starts a new chain', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();

    currentAchievementsState = currentAchievementsState.copyWith(
      isLoading: true,
    );
    achievementStates.add(currentAchievementsState);
    await tester.pump();

    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
    };
    currentAchievementsState = currentAchievementsState.copyWith(
      isLoading: false,
    );
    achievementStates.add(currentAchievementsState);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(guideState, isA<GuideRunning>());

    await disposeHost(tester);
  });

  testWidgets('a user change cancels stale retries and starts for the new user', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();

    userStates.add(
      UserState.loaded(
        _user.copyWith(id: 72),
      ),
    );
    await tester.pump();

    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
    };
    await tester.pump();
    await tester.pumpAndSettle();

    expect(guideState, isA<GuideRunning>());
    expect(repository.checkedUserIds, [72]);

    await disposeHost(tester);
  });

  testWidgets('does not start a guide with saved completion', (tester) async {
    repository.forceCompleted = true;
    renderedTargets.value = {
      ForgeAttributesGuideStep.intro,
      ForgeAttributesGuideStep.kobo,
    };

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.completed(
        guideId: GuideId.forgeAttributes,
      ),
    );
    expect(
      find.text(t.guides.forgeAttributes.introTitle),
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
