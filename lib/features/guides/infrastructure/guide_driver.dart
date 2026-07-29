import 'package:reforge/features/guides/domain/entities/guide_session.dart';

sealed class GuideDriverEvent {
  const GuideDriverEvent();
}

final class GuideStepStarted extends GuideDriverEvent {
  const GuideStepStarted(this.step);

  final int step;
}

final class GuideFinished extends GuideDriverEvent {
  const GuideFinished();
}

abstract interface class GuideDriver {
  Stream<GuideDriverEvent> get events;

  bool canStart(GuideSession session);

  void start(GuideSession session);

  void next();

  void previous();

  void dismiss();

  void dispose();
}
