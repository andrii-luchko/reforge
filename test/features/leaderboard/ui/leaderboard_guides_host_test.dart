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
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_guides_host.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../../helpers/test_setup.dart';

class _MockUserCubit extends MockCubit<UserState> implements UserCubit {}

class _MockImmortalForgesCubit extends MockCubit<ImmortalForgesState> implements ImmortalForgesCubit {}

class _MockFactionsLeaderboardCubit extends MockCubit<FactionsLeaderboardState> implements FactionsLeaderboardCubit {}

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  final Set<(int, GuideId)> completed = {};
  final List<(int, GuideId)> checks = [];

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    checks.add((userId, guideId));
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

const _leader = ImmortalForgeEntity(
  userId: 1,
  email: 'leader@example.com',
  score: 100,
  rank: 1,
  title: 'Daizōshō',
);

const _immortalForgesState = ImmortalForgesState(
  forgeData: {
    Faction.gakki: [_leader],
    Faction.gyohyo: [_leader],
    Faction.seiren: [_leader],
  },
);

const _factionsState = FactionsLeaderboardState(
  factions: [
    LeaderboardFactionModel(
      faction: Faction.gakki,
      xp: 1000,
      activeUsers: 10,
      globalScore: 2,
      localScore: 1,
    ),
    LeaderboardFactionModel(
      faction: Faction.gyohyo,
      xp: 900,
      activeUsers: 9,
      globalScore: 1,
      localScore: 0,
    ),
  ],
  userFaction: Faction.gakki,
);

void main() {
  initTestTranslations();

  late _MockUserCubit userCubit;
  late _MockImmortalForgesCubit immortalForgesCubit;
  late _MockFactionsLeaderboardCubit factionsCubit;
  late StreamController<UserState> userStates;
  late StreamController<ImmortalForgesState> immortalForgesStates;
  late StreamController<FactionsLeaderboardState> factionsStates;
  late ValueNotifier<LeaderboardMode> mode;
  late ValueNotifier<bool> renderLeaderboardTargets;
  late ValueNotifier<bool> renderFactionWarsTargets;
  late _MemoryGuideProgressRepository repository;
  GuideCubit? guideCubit;
  GuideState? guideState;

  setUp(() async {
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
    repository = _MemoryGuideProgressRepository();
    di.getIt.registerSingleton<GuideProgressRepository>(repository);

    userCubit = _MockUserCubit();
    immortalForgesCubit = _MockImmortalForgesCubit();
    factionsCubit = _MockFactionsLeaderboardCubit();
    userStates = StreamController<UserState>.broadcast();
    immortalForgesStates = StreamController<ImmortalForgesState>.broadcast();
    factionsStates = StreamController<FactionsLeaderboardState>.broadcast();
    mode = ValueNotifier(LeaderboardMode.users);
    renderLeaderboardTargets = ValueNotifier(false);
    renderFactionWarsTargets = ValueNotifier(false);
    guideCubit = null;
    guideState = null;

    whenListen(
      userCubit,
      userStates.stream,
      initialState: UserState.loaded(_user),
    );
    whenListen(
      immortalForgesCubit,
      immortalForgesStates.stream,
      initialState: _immortalForgesState,
    );
    whenListen(
      factionsCubit,
      factionsStates.stream,
      initialState: _factionsState,
    );
  });

  tearDown(() async {
    mode.dispose();
    renderLeaderboardTargets.dispose();
    renderFactionWarsTargets.dispose();
    await userStates.close();
    await immortalForgesStates.close();
    await factionsStates.close();
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
            BlocProvider<UserCubit>.value(value: userCubit),
            BlocProvider<ImmortalForgesCubit>.value(
              value: immortalForgesCubit,
            ),
            BlocProvider<FactionsLeaderboardCubit>.value(
              value: factionsCubit,
            ),
          ],
          child: LeaderboardGuidesHost(
            modeListenable: mode,
            child: Builder(
              builder: (context) {
                guideCubit = context.read<GuideCubit>();
                guideState = context.watch<GuideCubit>().state;
                final leaderboardGuide = context.read<LeaderboardGuide>();
                final factionWarsGuide = context.read<FactionWarsGuide>();

                return Scaffold(
                  body: ListenableBuilder(
                    listenable: Listenable.merge([
                      renderLeaderboardTargets,
                      renderFactionWarsTargets,
                    ]),
                    builder: (context, _) {
                      return Wrap(
                        children: [
                          if (renderLeaderboardTargets.value)
                            for (final step in LeaderboardGuideStep.values)
                              _target(
                                anchor: leaderboardGuide.anchor(step),
                                tooltip: leaderboardGuide.tooltip(step),
                                label: 'leaderboard-${step.name}',
                              ),
                          if (renderFactionWarsTargets.value)
                            for (final step in FactionWarsGuideStep.values)
                              _target(
                                anchor: factionWarsGuide.anchor(step),
                                tooltip: factionWarsGuide.tooltip(step),
                                label: 'faction-wars-${step.name}',
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

  testWidgets('runs leaderboard and Faction Wars sessions sequentially', (
    tester,
  ) async {
    renderLeaderboardTargets.value = true;
    renderFactionWarsTargets.value = true;

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.leaderboard,
        currentStep: 1,
        totalSteps: 8,
      ),
    );

    await guideCubit!.skip();
    await tester.pumpAndSettle();
    mode.value = LeaderboardMode.factions;
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.factionWars,
        currentStep: 1,
        totalSteps: 5,
      ),
    );
    expect(
      repository.checks,
      [
        (71, GuideId.leaderboard),
        (71, GuideId.factionWars),
      ],
    );

    await disposeHost(tester);
  });

  testWidgets('retries only while targets are not ready', (tester) async {
    await pumpHost(tester);
    await tester.pump();
    expect(guideState, const GuideState.initial());

    renderLeaderboardTargets.value = true;
    await tester.pump();
    await tester.pumpAndSettle();

    expect(guideState, isA<GuideRunning>());
    expect(repository.checks, [(71, GuideId.leaderboard)]);

    await disposeHost(tester);
  });

  testWidgets('does not orchestrate a known completed guide again', (
    tester,
  ) async {
    repository.completed.add((71, GuideId.leaderboard));
    renderLeaderboardTargets.value = true;

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.completed(guideId: GuideId.leaderboard),
    );
    expect(repository.checks, [(71, GuideId.leaderboard)]);

    immortalForgesStates.add(
      _immortalForgesState.copyWith(selectedFaction: Faction.gyohyo),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.checks, [(71, GuideId.leaderboard)]);

    await disposeHost(tester);
  });

  testWidgets('removes the mode listener and closes its cubit on dispose', (
    tester,
  ) async {
    await pumpHost(tester);
    final ownedCubit = guideCubit!;

    await disposeHost(tester);
    mode.value = LeaderboardMode.factions;
    await tester.pump();
    await pumpEventQueue();

    expect(ownedCubit.isClosed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

Widget _target({
  required GlobalKey anchor,
  required Widget tooltip,
  required String label,
}) {
  return GuideTarget(
    anchor: anchor,
    scope: leaderboardPageGuideScope,
    tooltip: tooltip,
    child: SizedBox(
      width: 48,
      height: 32,
      child: Text(label),
    ),
  );
}
