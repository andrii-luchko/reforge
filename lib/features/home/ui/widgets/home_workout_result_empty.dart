import 'package:flutter/material.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class HomeWorkoutResultEmpty extends StatelessWidget {
  const HomeWorkoutResultEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        children: [Text(context.t.home.workout_results.empty_data)],
      ),
    );
  }
}
