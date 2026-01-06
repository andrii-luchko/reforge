import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: appTheme.beige900,
                  border: Border.all(
                    color: appTheme.strokeCard,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppIconButton(iconAsset: Assets.images.icons.timer),
                    const SizedBox(height: 20),
                    Text('Total Duration', style: subheadH3Medium.copyWith(color: appTheme.beige100)),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '5', style: primaryStyle),
                          TextSpan(text: ' h ', style: secondaryStyle),
                          TextSpan(text: '20', style: primaryStyle),
                          TextSpan(text: ' m', style: secondaryStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: appTheme.beige900,
                  border: Border.all(
                    color: appTheme.strokeCard,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppIconButton(iconAsset: Assets.images.icons.dumbbell),
                    const SizedBox(height: 20),
                    Text('Workouts', style: subheadH3Medium.copyWith(color: appTheme.beige100)),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '5', style: primaryStyle),
                          TextSpan(text: ' / sessions', style: secondaryStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: appTheme.beige900,
            border: Border.all(
              color: appTheme.strokeCard,
            ),
          ),
          padding: const .all(16),
          child: Row(
            children: [
              AppIconButton(iconAsset: Assets.images.icons.calendar2),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: .start,
                spacing: 7,
                children: [
                  Text(
                    'Active Days',
                    style: subheadH3Medium.copyWith(color: appTheme.beige100),
                  ),

                  Text(
                    'Tuesday',
                    style: subheadH6Regular.copyWith(color: appTheme.beige600),
                  ),
                ],
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '1', style: primaryStyle),
                    TextSpan(text: ' / 3', style: secondaryStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
