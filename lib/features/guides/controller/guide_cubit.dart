import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/guide_driver.dart';

part 'guide_cubit.freezed.dart';
part 'guide_state.dart';

class GuideCubit extends Cubit<GuideState> {
  GuideCubit(this._progressRepository, this._driver) : super(const GuideState.initial()) {
    _driverSubscription = _driver.events.listen(_onDriverEvent);
  }

  final GuideProgressRepository _progressRepository;
  final GuideDriver _driver;
  late final StreamSubscription<GuideDriverEvent> _driverSubscription;

  GuideSession? _session;
  int? _userId;
  bool _startInProgress = false;
  bool _completionInProgress = false;
  final Set<(int, GuideId)> _completedGuides = {};

  bool shouldAttemptStart({
    required int userId,
    required GuideId guideId,
  }) {
    if (isClosed || state is GuideChecking || state is GuideRunning || _startInProgress) {
      return false;
    }

    return !_completedGuides.contains((userId, guideId));
  }

  Future<GuideStartResult> startIfNeeded({
    required int userId,
    required GuideSession session,
  }) async {
    if (isClosed || state is GuideChecking || state is GuideRunning || _startInProgress) {
      return GuideStartResult.ignored;
    }

    if (_completedGuides.contains((userId, session.id))) {
      return GuideStartResult.completed;
    }

    try {
      if (!_driver.canStart(session)) return GuideStartResult.notReady;
    } on Object {
      return GuideStartResult.failed;
    }

    _startInProgress = true;
    _completionInProgress = false;
    _session = null;
    _userId = userId;
    emit(GuideState.checking(guideId: session.id));

    try {
      final isCompleted = await _progressRepository.isCompleted(
        userId: userId,
        guideId: session.id,
      );
      if (isClosed) return GuideStartResult.ignored;

      if (isCompleted) {
        _completedGuides.add((userId, session.id));
        emit(GuideState.completed(guideId: session.id));
        return GuideStartResult.completed;
      }

      _session = session;
      emit(
        GuideState.running(
          guideId: session.id,
          currentStep: 1,
          totalSteps: session.steps.length,
        ),
      );
      _driver.start(session);
      return GuideStartResult.started;
    } on Object {
      if (!isClosed) {
        _session = null;
        _userId = null;
        emit(const GuideState.initial());
      }
      return GuideStartResult.failed;
    } finally {
      _startInProgress = false;
    }
  }

  void next() {
    if (state is GuideRunning) _driver.next();
  }

  void previous() {
    final currentState = state;
    if (currentState is GuideRunning && currentState.currentStep > 1) {
      _driver.previous();
    }
  }

  Future<void> skip() async {
    if (state is! GuideRunning || _completionInProgress) return;
    _driver.dismiss();
    await _complete();
  }

  Future<void> finish() => _complete();

  void _onDriverEvent(GuideDriverEvent event) {
    switch (event) {
      case GuideStepStarted(:final step):
        final session = _session;
        if (state is! GuideRunning || session == null) return;
        emit(
          GuideState.running(
            guideId: session.id,
            currentStep: step,
            totalSteps: session.steps.length,
          ),
        );
      case GuideFinished():
        unawaited(_complete());
    }
  }

  Future<void> _complete() async {
    final userId = _userId;
    final session = _session;
    if (state is! GuideRunning || userId == null || session == null || _completionInProgress) return;

    _completionInProgress = true;
    _completedGuides.add((userId, session.id));
    try {
      await _progressRepository.markCompleted(userId: userId, guideId: session.id);
    } on Object {
      // A failed local write should not keep an overlay open or crash the UI.
    } finally {
      if (!isClosed) emit(GuideState.completed(guideId: session.id));
    }
  }

  @override
  Future<void> close() async {
    await _driverSubscription.cancel();
    _driver.dispose();
    return super.close();
  }
}
