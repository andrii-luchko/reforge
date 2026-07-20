import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_congratulations/ui/pages/workout_congratulations_page.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/achievement_content_widget.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/share_content_widgets.dart';
import 'package:reforge/features/workout_congratulations/ui/widgets/congratulations/summary_content_widget.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_share/ui/widgets/share/share_dialog.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/horizontal_xp_bar.dart';

import '../../../core/analytics/mocks/mock_analytics_service.dart';

class _MockWorkoutFlowCubit extends Mock implements WorkoutFlowCubit {}

class _MockGoRouterState extends Mock implements GoRouterState {}

const _milestones = [
  UserWorkoutMilestoneEntity(
    id: 1,
    name: 'First milestone',
    tier: 1,
    iconUrl: null,
  ),
  UserWorkoutMilestoneEntity(
    id: 2,
    name: 'Second milestone',
    tier: 2,
    iconUrl: null,
  ),
];

WorkoutSessionSummaryEntity _summary({
  int id = 42,
  int xpEarned = 100,
  int duration = 320,
  List<UserWorkoutMilestoneEntity> milestones = const [],
}) {
  return WorkoutSessionSummaryEntity(
    id: id,
    duration: duration,
    totalXpEarned: xpEarned,
    earnedMilestones: milestones,
    isLevelUp: false,
    currentLevel: null,
  );
}

WorkoutFlowCubit _workoutFlowCubit(WorkoutSessionSummaryEntity? summary) {
  final cubit = _MockWorkoutFlowCubit();
  when(() => cubit.state).thenReturn(WorkoutFlowState(summary: summary));
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  return cubit;
}

void main() {
  late MockAnalyticsService analytics;

  setUp(() async {
    analytics = MockAnalyticsService();
    when(() => analytics.logEvent(any())).thenAnswer((_) async {});
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});

    if (di.getIt.isRegistered<AnalyticsService>()) {
      await di.getIt.unregister<AnalyticsService>();
    }
    di.getIt.registerSingleton<AnalyticsService>(analytics);
    di.getIt.registerSingleton<RouteObserver<ModalRoute<void>>>(RouteObserver<ModalRoute<void>>());
  });

  tearDown(() async {
    if (di.getIt.isRegistered<AnalyticsService>()) {
      await di.getIt.unregister<AnalyticsService>();
    }
    if (di.getIt.isRegistered<RouteObserver<ModalRoute<void>>>()) {
      await di.getIt.unregister<RouteObserver<ModalRoute<void>>>();
    }
  });

  Future<void> pumpPage(
    WidgetTester tester,
    WorkoutSessionSummaryEntity summary,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final workoutFlowCubit = _workoutFlowCubit(summary);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: BlocProvider<WorkoutFlowCubit>.value(
          value: workoutFlowCubit,
          child: const WorkoutCongratulationsPage(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  testWidgets('shows summary immediately when no milestones were earned', (tester) async {
    await pumpPage(tester, _summary());

    expect(find.byType(SummaryContentWidget), findsOneWidget);
    expect(find.byType(AchievementContentWidget), findsNothing);
  });

  testWidgets('shows each milestone once and then switches to summary', (tester) async {
    await pumpPage(tester, _summary(milestones: _milestones));

    expect(
      tester.widget<AchievementContentWidget>(find.byType(AchievementContentWidget)).milestone.name,
      'First milestone',
    );
    expect(find.byType(SummaryContentWidget), findsNothing);

    await tester.tap(find.text(t.common.next_button));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      tester.widget<AchievementContentWidget>(find.byType(AchievementContentWidget)).milestone.name,
      'Second milestone',
    );

    await tester.tap(find.text(t.common.next_button));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(SummaryContentWidget), findsOneWidget);
    verify(
      () => analytics.logEvent(
        AnalyticsEvents.workoutBadgeEarned,
        any(),
      ),
    ).called(2);
  });

  testWidgets('uses stable XP-based progress for screen and share content', (tester) async {
    Future<double> readProgress(int xpEarned) async {
      await pumpPage(tester, _summary(xpEarned: xpEarned));

      final screenProgress = tester.widget<HorizontalXPBar>(find.byType(HorizontalXPBar)).progress;
      final shareButton = tester.widget<ShareButton>(find.byType(ShareButton));
      final shareContent = shareButton.shareContent as SummaryShareContent;

      expect(shareContent.xpProgress, screenProgress);
      expect(screenProgress, inInclusiveRange(0.2, 0.7));
      return screenProgress;
    }

    final lowProgress = await readProgress(100);
    final repeatedLowProgress = await readProgress(100);
    final highProgress = await readProgress(300);
    final minimumProgress = await readProgress(0);
    final maximumProgress = await readProgress(1000);

    expect(repeatedLowProgress, lowProgress);
    expect(highProgress, greaterThan(lowProgress));
    expect(minimumProgress, inInclusiveRange(0.2, 0.7));
    expect(maximumProgress, inInclusiveRange(0.2, 0.7));
  });

  testWidgets('formats duration identically in screen and share summary', (tester) async {
    const durationText = '5m 20s';
    final summary = _summary();
    await pumpPage(tester, summary);

    expect(find.text(durationText), findsOneWidget);

    final shareButton = tester.widget<ShareButton>(find.byType(ShareButton));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(body: shareButton.shareContent),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text(durationText), findsOneWidget);
  });

  testWidgets('finish navigates to home and logs analytics', (tester) async {
    final workoutFlowCubit = _workoutFlowCubit(_summary());

    final router = GoRouter(
      initialLocation: '/workout-congratulations',
      routes: [
        GoRoute(
          path: '/workout-congratulations',
          builder: (context, state) => const WorkoutCongratulationsPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<WorkoutFlowCubit>.value(
        value: workoutFlowCubit,
        child: MaterialApp.router(
          theme: ThemeDataValues.darkThemeData,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(t.common.finish_button));
    await tester.pumpAndSettle();

    expect(find.text('Home destination'), findsOneWidget);
    verify(() => analytics.logEvent(AnalyticsEvents.workoutSummaryFinishClick)).called(1);
  });

  testWidgets('route redirects home when workout summary is missing', (tester) async {
    final workoutFlowCubit = _workoutFlowCubit(null);
    String? redirect;

    await tester.pumpWidget(
      BlocProvider<WorkoutFlowCubit>.value(
        value: workoutFlowCubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              redirect = const WorkoutCongratulationsPageRoute().redirect(
                context,
                _MockGoRouterState(),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(redirect, const HomePageRoute().location);
  });
}
