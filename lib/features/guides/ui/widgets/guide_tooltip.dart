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
        final isLastStep = currentStep >= totalSteps;

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
                  _GuideControls(
                    canGoBack: currentStep > 1,
                    isLastStep: isLastStep,
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

class _GuideControls extends StatelessWidget {
  const _GuideControls({
    required this.canGoBack,
    required this.isLastStep,
  });

  final bool canGoBack;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final back = TextButton(
      onPressed: canGoBack ? context.read<GuideCubit>().previous : null,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(t.guides.controls.back),
    );
    final skip = TextButton(
      onPressed: context.read<GuideCubit>().skip,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(t.guides.controls.skip),
    );
    final next = FilledButton(
      onPressed: context.read<GuideCubit>().next,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isLastStep ? t.guides.controls.finish : t.guides.controls.next,
      ),
    );

    return Row(
      spacing: 4,

      children: [
        back,
        const Spacer(),
        if (!isLastStep) skip,
        next,
      ],
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
