import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    return false;
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {}
}

class _MockImmortalForgesCubit extends MockCubit<ImmortalForgesState> implements ImmortalForgesCubit {}

const _leader = ImmortalForgeEntity(
  userId: 1,
  email: 'leader@example.com',
  score: 100,
  rank: 1,
  title: 'Daizōshō',
);

void main() {
  initTestTranslations();

  testWidgets('renders a tooltip for a full-screen guide target', (tester) async {
    const scope = 'full-screen-guide-target-test';
    final anchor = GlobalKey();
    final cubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: scope),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: BlocProvider<GuideCubit>.value(
          value: cubit,
          child: Scaffold(
            body: GuideTarget(
              anchor: anchor,
              scope: scope,
              guideCubit: cubit,
              targetPadding: EdgeInsets.zero,
              targetBorderRadius: BorderRadius.zero,
              tooltip: const GuideTooltip(
                title: 'Leaderboard',
                description: 'Guide introduction',
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    await cubit.startIfNeeded(
      userId: 71,
      session: GuideSession(
        id: GuideId.leaderboard,
        steps: [GuideStep(anchor: anchor)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('moves from intro to faction selector without a dry-layout error', (tester) async {
    const scope = 'guide-target-transition-test';
    final guide = LeaderboardGuide();
    final immortalForgesCubit = _MockImmortalForgesCubit();
    const immortalForgesState = ImmortalForgesState(
      forgeData: {
        Faction.gakki: [_leader],
        Faction.gyohyo: [_leader],
        Faction.seiren: [_leader],
      },
    );
    when(() => immortalForgesCubit.state).thenReturn(immortalForgesState);
    when(() => immortalForgesCubit.stream).thenAnswer((_) => const Stream.empty());

    final cubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: scope),
    );
    addTearDown(cubit.close);
    addTearDown(immortalForgesCubit.close);

    final introAnchor = guide.anchor(LeaderboardGuideStep.intro);
    final factionAnchor = guide.anchor(LeaderboardGuideStep.factionSelector);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: BlocProvider<GuideCubit>.value(
          value: cubit,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: GuideTarget(
                    anchor: introAnchor,
                    scope: scope,
                    guideCubit: cubit,
                    tooltip: guide.tooltip(LeaderboardGuideStep.intro),
                    child: const ColoredBox(color: Colors.red),
                  ),
                ),
                Expanded(
                  child: GuideTarget(
                    anchor: factionAnchor,
                    scope: scope,
                    guideCubit: cubit,
                    tooltip: guide.tooltip(
                      LeaderboardGuideStep.factionSelector,
                      immortalForgesCubit: immortalForgesCubit,
                    ),
                    child: const ColoredBox(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await cubit.startIfNeeded(
      userId: 71,
      session: GuideSession(
        id: GuideId.leaderboard,
        steps: [
          GuideStep(anchor: introAnchor),
          GuideStep(anchor: factionAnchor),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.guides.controls.next));
    await tester.pumpAndSettle();

    expect(find.text(t.guides.leaderboard.factionTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
