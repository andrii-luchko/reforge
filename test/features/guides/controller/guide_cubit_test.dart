import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/guide_driver.dart';

class _MockGuideProgressRepository extends Mock implements GuideProgressRepository {}

class _FakeGuideDriver implements GuideDriver {
  final StreamController<GuideDriverEvent> _events = StreamController.broadcast(sync: true);

  bool isReady = true;
  int startCalls = 0;
  int nextCalls = 0;
  int previousCalls = 0;
  int dismissCalls = 0;
  int disposeCalls = 0;

  @override
  Stream<GuideDriverEvent> get events => _events.stream;

  @override
  bool canStart(GuideSession session) => isReady;

  @override
  void start(GuideSession session) {
    startCalls++;
  }

  @override
  void next() {
    nextCalls++;
  }

  @override
  void previous() {
    previousCalls++;
  }

  @override
  void dismiss() {
    dismissCalls++;
  }

  @override
  void dispose() {
    disposeCalls++;
    unawaited(_events.close());
  }

  void emit(GuideDriverEvent event) => _events.add(event);
}

GuideSession _session([GuideId id = GuideId.leaderboard]) {
  return GuideSession(
    id: id,
    steps: [
      GuideStep(anchor: GlobalKey()),
      GuideStep(anchor: GlobalKey()),
    ],
  );
}

void main() {
  late _MockGuideProgressRepository repository;
  late _FakeGuideDriver driver;
  late GuideCubit cubit;

  setUp(() {
    repository = _MockGuideProgressRepository();
    driver = _FakeGuideDriver();
    cubit = GuideCubit(repository, driver);
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test('does not check or start until every target is rendered', () async {
    driver.isReady = false;

    await cubit.startIfNeeded(userId: 71, session: _session());

    expect(cubit.state, const GuideState.initial());
    expect(driver.startCalls, 0);
    verifyNever(
      () => repository.isCompleted(
        userId: 71,
        guideId: GuideId.leaderboard,
      ),
    );
  });

  test('does not start a completed guide', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => true);

    await cubit.startIfNeeded(userId: 71, session: _session());

    expect(cubit.state, const GuideState.completed(guideId: GuideId.leaderboard));
    expect(driver.startCalls, 0);
  });

  test('starts once and mirrors driver navigation events', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);

    final session = _session();
    await cubit.startIfNeeded(userId: 71, session: session);
    await cubit.startIfNeeded(userId: 71, session: session);

    expect(
      cubit.state,
      const GuideState.running(
        guideId: GuideId.leaderboard,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    expect(driver.startCalls, 1);

    cubit.next();
    expect(driver.nextCalls, 1);

    driver.emit(const GuideStepStarted(2));
    expect(
      cubit.state,
      const GuideState.running(
        guideId: GuideId.leaderboard,
        currentStep: 2,
        totalSteps: 2,
      ),
    );

    cubit.previous();
    expect(driver.previousCalls, 1);
  });

  test('skip dismisses and stores completion once', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async {});
    await cubit.startIfNeeded(userId: 71, session: _session());
    await Future.wait([cubit.skip(), cubit.skip()]);

    expect(driver.dismissCalls, 1);
    expect(cubit.state, const GuideState.completed(guideId: GuideId.leaderboard));
    verify(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).called(1);
  });

  test('driver finish stores completion', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async {});
    await cubit.startIfNeeded(userId: 71, session: _session());
    driver.emit(const GuideFinished());
    await pumpEventQueue();

    expect(cubit.state, const GuideState.completed(guideId: GuideId.leaderboard));
    verify(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).called(1);
  });

  test('repeated finish stores completion once', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async {});

    await cubit.startIfNeeded(userId: 71, session: _session());
    await Future.wait([cubit.finish(), cubit.finish()]);

    expect(cubit.state, const GuideState.completed(guideId: GuideId.leaderboard));
    verify(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).called(1);
  });

  test('closing an active guide does not store completion', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);

    await cubit.startIfNeeded(userId: 71, session: _session());
    await cubit.close();

    expect(driver.disposeCalls, 1);
    verifyNever(
      () => repository.markCompleted(
        userId: 71,
        guideId: GuideId.leaderboard,
      ),
    );
  });

  test('starts a different guide after completing the first one', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.factionWars),
    ).thenAnswer((_) async => false);
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async {});
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.factionWars),
    ).thenAnswer((_) async {});

    await cubit.startIfNeeded(userId: 71, session: _session());
    await cubit.finish();
    await cubit.startIfNeeded(
      userId: 71,
      session: _session(GuideId.factionWars),
    );

    expect(driver.startCalls, 2);
    expect(
      cubit.state,
      const GuideState.running(
        guideId: GuideId.factionWars,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    await cubit.finish();
    verify(
      () => repository.markCompleted(
        userId: 71,
        guideId: GuideId.leaderboard,
      ),
    ).called(1);
    verify(
      () => repository.markCompleted(
        userId: 71,
        guideId: GuideId.factionWars,
      ),
    ).called(1);
  });

  test('does not replace an active guide with another session', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);

    await cubit.startIfNeeded(userId: 71, session: _session());
    await cubit.startIfNeeded(
      userId: 71,
      session: _session(GuideId.factionWars),
    );

    expect(driver.startCalls, 1);
    expect(
      cubit.state,
      const GuideState.running(
        guideId: GuideId.leaderboard,
        currentStep: 1,
        totalSteps: 2,
      ),
    );
    verifyNever(
      () => repository.isCompleted(
        userId: 71,
        guideId: GuideId.factionWars,
      ),
    );
  });

  test('does not restart the same guide after completing it', () async {
    when(
      () => repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async => false);
    when(
      () => repository.markCompleted(userId: 71, guideId: GuideId.leaderboard),
    ).thenAnswer((_) async {});

    final session = _session();
    await cubit.startIfNeeded(userId: 71, session: session);
    await cubit.finish();
    await cubit.startIfNeeded(userId: 71, session: session);

    expect(driver.startCalls, 1);
    verify(
      () => repository.isCompleted(
        userId: 71,
        guideId: GuideId.leaderboard,
      ),
    ).called(1);
  });
}
