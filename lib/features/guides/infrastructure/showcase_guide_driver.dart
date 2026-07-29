import 'dart:async';

import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/infrastructure/guide_driver.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowcaseGuideDriver implements GuideDriver {
  ShowcaseGuideDriver({required String scope}) {
    _showcaseView = ShowcaseView.register(
      scope: scope,
      disableBarrierInteraction: true,
      onStart: (index, _) {
        if (index == null || _events.isClosed) return;
        _events.add(GuideStepStarted(index + 1));
      },
      onFinish: () {
        if (!_events.isClosed) _events.add(const GuideFinished());
      },
    );
  }

  final StreamController<GuideDriverEvent> _events = StreamController.broadcast(sync: true);
  late final ShowcaseView _showcaseView;
  bool _disposed = false;

  @override
  Stream<GuideDriverEvent> get events => _events.stream;

  @override
  bool canStart(GuideSession session) {
    return !_disposed && session.steps.every((step) => _showcaseView.isTargetRendered(step.anchor));
  }

  @override
  void start(GuideSession session) {
    if (_disposed) return;
    _showcaseView.startShowCase(session.steps.map((step) => step.anchor).toList(growable: false));
  }

  @override
  void next() {
    if (!_disposed) _showcaseView.next(force: true);
  }

  @override
  void previous() {
    if (!_disposed) _showcaseView.previous();
  }

  @override
  void dismiss() {
    if (!_disposed) _showcaseView.dismiss();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _showcaseView.unregister();
    unawaited(_events.close());
  }
}
