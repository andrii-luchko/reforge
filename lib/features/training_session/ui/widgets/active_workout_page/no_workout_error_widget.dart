import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class NoWorkoutErrorWidget extends StatelessWidget {
  const NoWorkoutErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      margin: const .all(16),
      padding: const .all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),

      child: Column(
        children: [
          const Icon(Icons.error),
          Text(
            'Something went wrong and we cant find right exercise\nPlease try again later',
            style: subheadH1Medium.copyWith(
              color: appTheme.beige100,
            ),
          ),
        ],
      ),
    );
  }
}
