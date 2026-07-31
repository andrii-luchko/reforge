import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/guide/home_page_guide_scope.dart';
import 'package:reforge/features/home/ui/guide/main_page_guide_host.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  bool isCompletedValue = false;
  final List<(int, GuideId)> checks = [];

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    checks.add((userId, guideId));
    return isCompletedValue;
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {}
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

HomeState _readyState() {
  final stats = UserStats.newUser();
  return HomeState(
    user: _user,
    rank: RankEntity.mockWith(t),
    statsMap: {StatsPeriod.lastWeek: stats},
  );
}

Widget _target({
  required MainPageGuide guide,
  required MainPageGuideStep step,
}) {
  return GuideTarget(
    anchor: guide.anchor(step),
    scope: homePageGuideScope,
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

  late _MockHomeCubit homeCubit;
  late StreamController<HomeState> homeStates;
  late ValueNotifier<Set<MainPageGuideStep>> renderedTargets;
  late _MemoryGuideProgressRepository repository;
  GuideState? guideState;

  setUp(() async {
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
    repository = _MemoryGuideProgressRepository();
    di.getIt.registerSingleton<GuideProgressRepository>(repository);

    homeCubit = _MockHomeCubit();
    homeStates = StreamController<HomeState>.broadcast();
    renderedTargets = ValueNotifier({
      MainPageGuideStep.characterEvolution,
    });
    guideState = null;

    whenListen(
      homeCubit,
      homeStates.stream,
      initialState: _readyState(),
    );
  });

  tearDown(() async {
    renderedTargets.dispose();
    await homeStates.close();
    if (di.getIt.isRegistered<GuideProgressRepository>()) {
      await di.getIt.unregister<GuideProgressRepository>();
    }
  });

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: BlocProvider<HomeCubit>.value(
          value: homeCubit,
          child: MainPageGuideHost(
            child: Builder(
              builder: (context) {
                guideState = context.watch<GuideCubit>().state;
                final guide = context.read<MainPageGuide>();

                return Scaffold(
                  body: ValueListenableBuilder<Set<MainPageGuideStep>>(
                    valueListenable: renderedTargets,
                    builder: (context, targets, _) {
                      return Column(
                        children: [
                          for (final step in MainPageGuideStep.values)
                            if (targets.contains(step)) _target(guide: guide, step: step),
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

  testWidgets('retries until all Main Page targets are mounted', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.pump();
    expect(guideState, const GuideState.initial());

    renderedTargets.value = MainPageGuideStep.values.toSet();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.running(
        guideId: GuideId.mainPage,
        currentStep: 1,
        totalSteps: 3,
      ),
    );
    expect(repository.checks, [(71, GuideId.mainPage)]);

    await disposeHost(tester);
  });

  testWidgets('does not render a completed Main Page guide', (tester) async {
    repository.isCompletedValue = true;
    renderedTargets.value = MainPageGuideStep.values.toSet();

    await pumpHost(tester);
    await tester.pumpAndSettle();

    expect(
      guideState,
      const GuideState.completed(guideId: GuideId.mainPage),
    );
    expect(find.text(t.guides.mainPage.characterEvolutionTitle), findsNothing);

    await disposeHost(tester);
  });
}
