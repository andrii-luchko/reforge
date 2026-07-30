import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class GuideTooltip extends StatelessWidget {
  const GuideTooltip({
    required this.title,
    this.description,
    this.subtitle,
    this.additionalContent,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return BlocBuilder<GuideCubit, GuideState>(
      builder: (context, state) {
        final runningState = state is GuideRunning ? state : null;
        final currentStep = runningState?.currentStep ?? 1;
        final totalSteps = runningState?.totalSteps ?? 1;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.beige900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.strokeCard),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$currentStep / $totalSteps', style: bodyLRegular.copyWith(color: theme.beige700)),
                  const SizedBox(height: 8),
                  Text(title, style: subheadH3Medium.copyWith(color: theme.beige100)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle!, style: subheadH6Regular.copyWith(color: theme.orange500)),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(description!, style: bodyMRegular.copyWith(color: theme.beige300, height: 1.35)),
                  ],
                  if (additionalContent != null) ...[
                    const SizedBox(height: 12),
                    additionalContent!,
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: currentStep == 1 ? null : context.read<GuideCubit>().previous,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(t.guides.controls.back),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: context.read<GuideCubit>().skip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(t.guides.controls.skip),
                      ),
                      const SizedBox(width: 4),
                      FilledButton(
                        onPressed: context.read<GuideCubit>().next,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(t.guides.controls.next),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GuideLectureSection extends StatelessWidget {
  const GuideLectureSection({required this.description, required this.subtitle, super.key});

  final String description;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        ...[
          const SizedBox(height: 8),
          Text(subtitle, style: subheadH6Regular.copyWith(color: theme.orange500)),
        ],
        const SizedBox(height: 8),
        Text(description, style: bodyMRegular.copyWith(color: theme.beige300, height: 1.35)),
      ],
    );
  }
}
