import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/running_milestone.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_candidate_repository.dart';
import 'package:reforge/features/running/domain/repositories/running_milestone_repository.dart';

@lazySingleton
class RunningMilestoneSender {
  RunningMilestoneSender(this._candidateRepository, this._milestoneRepository);

  final RunningMilestoneCandidateRepository _candidateRepository;
  final RunningMilestoneRepository _milestoneRepository;

  // ignore: cancel_subscriptions, canceled by the idempotent stop lifecycle
  StreamSubscription<List<PendingRunningMilestone>>? _subscription;
  Timer? _pollTimer;
  Future<void>? _pollFuture;
  final Map<int, Future<void>> _inFlight = {};
  int? _workoutSessionId;

  Future<void> start(int workoutSessionId) async {
    if (_workoutSessionId == workoutSessionId && _subscription != null) return;
    await stop();
    _workoutSessionId = workoutSessionId;
    _subscription = _candidateRepository
        .watchPendingCandidates(workoutSessionId)
        .listen(
          _scheduleAll,
          onError: (Object error, StackTrace stackTrace) {
            logger.w('RunningMilestoneSender: pending candidate watcher failed', error, stackTrace);
          },
        );

    // The background worker can own a separate Drift connection/process, so
    // its writes do not reliably invalidate main-isolate query streams.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_pollPending(workoutSessionId)),
    );
    await _pollPending(workoutSessionId);
  }

  Future<void> drain(int workoutSessionId) async {
    await start(workoutSessionId);
    await _pollPending(workoutSessionId);

    final current = _inFlight.values.toList(growable: false);
    if (current.isNotEmpty) await Future.wait(current);
  }

  Future<void> stop([int? workoutSessionId]) async {
    if (workoutSessionId != null && _workoutSessionId != workoutSessionId) return;
    final subscription = _subscription;
    _subscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _workoutSessionId = null;
    await subscription?.cancel();
    await _pollFuture;
  }

  Future<void> _pollPending(int workoutSessionId) {
    final existing = _pollFuture;
    if (existing != null) return existing;

    final future = _pollPendingOnce(workoutSessionId);
    _pollFuture = future;
    return future.whenComplete(() {
      if (identical(_pollFuture, future)) _pollFuture = null;
    });
  }

  Future<void> _pollPendingOnce(int workoutSessionId) async {
    try {
      final candidates = await _candidateRepository.getPendingCandidates(workoutSessionId);
      if (_workoutSessionId == workoutSessionId) _scheduleAll(candidates);
    } on Exception catch (error, stackTrace) {
      logger.w('RunningMilestoneSender: failed to load pending candidates', error, stackTrace);
    }
  }

  void _scheduleAll(List<PendingRunningMilestone> candidates) {
    for (final candidate in candidates) {
      if (_inFlight.containsKey(candidate.id)) continue;
      late final Future<void> attempt;
      attempt = _attempt(candidate).whenComplete(() {
        if (identical(_inFlight[candidate.id], attempt)) {
          final _ = _inFlight.remove(candidate.id);
        }
      });
      _inFlight[candidate.id] = attempt;
    }
  }

  Future<void> _attempt(PendingRunningMilestone candidate) async {
    try {
      final claimed = await _candidateRepository.claimAttempt(candidate.id);
      if (!claimed) return;
      await _milestoneRepository.calculateRunningMilestone(candidate.payload);
      logger.i(
        'Running milestone sent workoutSessionId=${candidate.payload.workoutSessionId} '
        'runningSetId=${candidate.payload.runningSetId} key=${candidate.payload.milestoneKey.apiValue}',
      );
    } on Exception catch (error, stackTrace) {
      logger.w(
        'RunningMilestoneSender: first attempt failed '
        'workoutSessionId=${candidate.payload.workoutSessionId} '
        'runningSetId=${candidate.payload.runningSetId} key=${candidate.payload.milestoneKey.apiValue}',
        error,
        stackTrace,
      );
    }
  }
}
