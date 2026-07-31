import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/factions_leaderboard_view.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../helpers/test_setup.dart';

class _MockGuideCubit extends MockCubit<GuideState> implements GuideCubit {}

class _MockFactionsLeaderboardCubit extends MockCubit<FactionsLeaderboardState> implements FactionsLeaderboardCubit {}

const _factions = [
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
  LeaderboardFactionModel(
    faction: Faction.seiren,
    xp: 800,
    activeUsers: 8,
    globalScore: 0,
    localScore: 0,
  ),
];

void main() {
  initTestTranslations();

  testWidgets('mounts battle-mode, scoring, victory-points, and monthly-rewards targets', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final guideCubit = _MockGuideCubit();
    final factionsCubit = _MockFactionsLeaderboardCubit();
    const state = FactionsLeaderboardState(
      factions: _factions,
      userFaction: Faction.gakki,
    );
    when(() => guideCubit.state).thenReturn(
      const GuideState.running(
        guideId: GuideId.factionWars,
        currentStep: 1,
        totalSteps: 5,
      ),
    );
    when(() => guideCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => factionsCubit.state).thenReturn(state);
    when(() => factionsCubit.stream).thenAnswer((_) => const Stream.empty());

    final showcaseView = ShowcaseView.register(scope: leaderboardPageGuideScope);
    addTearDown(showcaseView.unregister);
    di.getIt.registerSingleton<RouteObserver<ModalRoute<void>>>(RouteObserver<ModalRoute<void>>());
    addTearDown(() => di.getIt.unregister<RouteObserver<ModalRoute<void>>>());

    final guide = FactionWarsGuide();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<GuideCubit>.value(value: guideCubit),
            BlocProvider<FactionsLeaderboardCubit>.value(value: factionsCubit),
          ],
          child: Provider<FactionWarsGuide>.value(
            value: guide,
            child: const Scaffold(
              body: CustomScrollView(
                scrollCacheExtent: ScrollCacheExtent.pixels(1200),
                slivers: [FactionsLeaderboardView()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GuideTarget), findsNWidgets(4));
    expect(
      showcaseView.isTargetRendered(
        guide.anchor(FactionWarsGuideStep.battleMode),
      ),
      isTrue,
    );
    expect(
      showcaseView.isTargetRendered(guide.anchor(FactionWarsGuideStep.scoring)),
      isTrue,
    );
    expect(
      showcaseView.isTargetRendered(
        guide.anchor(FactionWarsGuideStep.victoryPoints),
      ),
      isTrue,
    );
    expect(
      showcaseView.isTargetRendered(
        guide.anchor(FactionWarsGuideStep.monthlyRewards),
      ),
      isTrue,
    );
    expect(find.byKey(const ValueKey('monthly-reward-banner')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
