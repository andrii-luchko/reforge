import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_page_guide_scope.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users/immortal_forges_card.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../helpers/test_setup.dart';

class _MockGuideCubit extends MockCubit<GuideState> implements GuideCubit {}

class _MockImmortalForgesCubit extends MockCubit<ImmortalForgesState> implements ImmortalForgesCubit {}

const _leader = ImmortalForgeEntity(
  userId: 1,
  email: 'leader@example.com',
  score: 100,
  rank: 1,
  title: 'Daizōshō',
);

Widget _harness({
  required GuideCubit guideCubit,
  required Widget child,
}) {
  return MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: Scaffold(
      body: Center(
        child: BlocProvider<GuideCubit>.value(
          value: guideCubit,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  initTestTranslations();

  late _MockGuideCubit guideCubit;
  late _MockImmortalForgesCubit immortalForgesCubit;

  setUp(() {
    guideCubit = _MockGuideCubit();
    immortalForgesCubit = _MockImmortalForgesCubit();

    when(
      () => guideCubit.state,
    ).thenReturn(
      const GuideState.running(
        guideId: GuideId.leaderboard,
        currentStep: 2,
        totalSteps: 8,
      ),
    );
    when(() => guideCubit.stream).thenAnswer((_) => const Stream.empty());
    when(guideCubit.next).thenReturn(null);
    when(guideCubit.previous).thenReturn(null);
    when(guideCubit.skip).thenAnswer((_) async {});
  });

  testWidgets('guide tooltip delegates navigation to GuideCubit', (tester) async {
    await tester.pumpWidget(
      _harness(
        guideCubit: guideCubit,
        child: const GuideTooltip(
          title: 'Title',
          description: 'Description',
        ),
      ),
    );

    expect(find.text('2 / 8'), findsOneWidget);

    await tester.tap(find.text(t.guides.controls.back));
    await tester.tap(find.text(t.guides.controls.next));
    await tester.tap(find.text(t.guides.controls.skip));
    await tester.pump();

    verify(guideCubit.previous).called(1);
    verify(guideCubit.next).called(1);
    verify(guideCubit.skip).called(1);
  });

  testWidgets('Might content follows the selected faction', (tester) async {
    const state = ImmortalForgesState(
      selectedFaction: Faction.gyohyo,
      forgeData: {
        Faction.gyohyo: [_leader],
      },
    );
    when(() => immortalForgesCubit.state).thenReturn(state);
    when(() => immortalForgesCubit.stream).thenAnswer((_) => const Stream.empty());

    final guide = LeaderboardGuide();
    await tester.pumpWidget(
      _harness(
        guideCubit: guideCubit,
        child: guide.tooltip(
          LeaderboardGuideStep.might,
          immortalForgesCubit: immortalForgesCubit,
        ),
      ),
    );

    expect(find.text(t.guides.leaderboard.runningTitle), findsOneWidget);
    expect(find.text(t.guides.leaderboard.runningDescription), findsOneWidget);
    expect(find.text(t.guides.leaderboard.strengthDescription), findsNothing);
  });

  testWidgets('a partial non-empty card still exposes all five rank anchors', (tester) async {
    const state = ImmortalForgesState(
      forgeData: {
        Faction.gakki: [_leader],
      },
    );
    when(() => immortalForgesCubit.state).thenReturn(state);
    when(() => immortalForgesCubit.stream).thenAnswer((_) => const Stream.empty());

    final showcaseView = ShowcaseView.register(scope: leaderboardPageGuideScope);
    addTearDown(showcaseView.unregister);
    di.getIt.registerSingleton<RouteObserver<ModalRoute<void>>>(RouteObserver<ModalRoute<void>>());
    addTearDown(() => di.getIt.unregister<RouteObserver<ModalRoute<void>>>());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<GuideCubit>.value(value: guideCubit),
            BlocProvider<ImmortalForgesCubit>.value(value: immortalForgesCubit),
          ],
          child: Scaffold(
            body: ImmortalForcesCard(
              users: const [_leader],
              guide: LeaderboardGuide(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GuideTarget), findsNWidgets(5));
  });
}
