import 'package:flutter/widgets.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';

class GuideStep {
  const GuideStep({required this.anchor});

  final GlobalKey anchor;
}

class GuideSession {
  GuideSession({
    required this.id,
    required List<GuideStep> steps,
  }) : assert(steps.isNotEmpty, 'A guide session must contain at least one step'),
       steps = List.unmodifiable(steps);

  final GuideId id;
  final List<GuideStep> steps;
}
