import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class NoWorkoutErrorWidget extends StatelessWidget {
  const NoWorkoutErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      margin: const .all(16),
      padding: const .all(16),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),

      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        spacing: 16,
        children: [
          const Icon(Icons.error, size: 48),

          Text(
            t.workout.exerciseNotFoundError,
            style: subheadH1Medium.copyWith(
              color: appTheme.beige100,
            ),
            textAlign: .center,
          ),
        ],
      ),
    );
  }
}
