import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/duration_extensions.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/uikit/app_svg_icon.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:toastification/toastification.dart';

class AudioHintDialog extends StatelessWidget {
  const AudioHintDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppDialog.show<void>(
      context,
      child: const AudioHintDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.running.audio_hint.workout_cues,
            style: subheadH2Medium.copyWith(color: theme.beige100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 160,
            child: BadgeImage.asset(
              asset: Assets.images.png.magnificHammer.path,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t.running.audio_hint.follow_hammer,
            style: subheadH1Medium.copyWith(color: theme.beige100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "The hammer sound will guide you through each interval. One strike means it's time to switch pace, while three strikes indicate you've completed the workout.",
            style: bodyLRegular.copyWith(color: theme.beige600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            text: t.running.audio_hint.got_it,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class SegmentHint extends StatelessWidget {
  const SegmentHint({required this.segment, required this.measureSystem, this.onClose, super.key});

  final ExerciseSegmentEntity segment;
  final MeasurementSystem measureSystem;
  final VoidCallback? onClose;

  static void show(BuildContext context, ExerciseSegmentEntity segment, MeasurementSystem measureSystem) {
    toastification.showCustom(
      alignment: Alignment.topCenter,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      builder: (context, item) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Align(
            alignment: item.alignment,
            child: GestureDetector(
              onTap: () => toastification.dismiss(item),
              onHorizontalDragStart: (_) => toastification.dismiss(item),
              child: SegmentHint(
                segment: segment,
                measureSystem: measureSystem,
                onClose: () => toastification.dismiss(item),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final target = _formatTarget(segment);
    final recommendedSpeed = segment.recommendedSpeed;
    final activity = switch (segment.activity) {
      SegmentActivity.walk when segment.targetMetric == WorkoutMetric.time => t.running.audio_hint.recovery_walk,
      _ => segment.activity.title,
    };
    final icon = switch (segment.activity) {
      SegmentActivity.walk => Icons.directions_walk,
      _ => Icons.directions_run,
    };

    return Container(
      // width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.beige900,
        border: Border.all(color: theme.strokeCard),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.orange400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.beige100, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.running.active.current_lap,
                  style: bodySRegular.copyWith(color: theme.beige600),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: subheadH5Medium.copyWith(color: theme.beige100),
                    children: [
                      TextSpan(text: activity),
                      if (target != null) ...[
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: target,
                          style: subheadH5Medium.copyWith(color: theme.orange500),
                        ),
                      ],
                    ],
                  ),
                ),
                if (recommendedSpeed != null) ...[
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: bodySRegular.copyWith(color: theme.beige600),
                      children: [
                        TextSpan(text: '${t.running.active.speed_hint} '),
                        TextSpan(
                          text: _formatRecommendedSpeed(recommendedSpeed),
                          style: subheadH7Medium.copyWith(color: theme.beige100, fontSize: bodySRegular.fontSize),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: AppSvgIcon(
                asset: Assets.images.icons.close,
                color: context.appTheme.beige400,
              ),
            ),
        ],
      ),
    );
  }

  String? _formatTarget(ExerciseSegmentEntity segment) {
    return switch (segment.targetMetric) {
      WorkoutMetric.time => Duration(seconds: segment.durationSec).toDigital(),
      WorkoutMetric.distance => _formatDistance(segment.distanceM, measureSystem),
      _ => null,
    };
  }

  String _formatRecommendedSpeed(double speedKmH) {
    final isImperial = measureSystem == MeasurementSystem.imperial;
    final speed = isImperial ? MeasureSystemValues.toMiles(speedKmH) : speedKmH;
    final unit = isImperial ? t.measure_system.speed.imperial_symbol : t.measure_system.speed.metric_symbol;
    return '${speed.toStringAsFixed(1)} $unit';
  }

  String _formatDistance(double meters, MeasurementSystem system) {
    if (system == MeasurementSystem.imperial) {
      final miles = MeasureSystemValues.toMiles(meters / 1000);
      final value = miles == miles.roundToDouble()
          ? miles.toInt().toString()
          : miles < 1
          ? miles.toStringAsFixed(2)
          : miles.toStringAsFixed(1);
      return '$value ${t.measure_system.distance.imperial_symbol}';
    }

    if (meters >= 1000) {
      final kilometers = meters / 1000;
      final value = kilometers == kilometers.roundToDouble()
          ? kilometers.toInt().toString()
          : kilometers.toStringAsFixed(1);
      return '$value km';
    }

    final value = meters == meters.roundToDouble() ? meters.toInt().toString() : meters.toStringAsFixed(1);
    return '$value m';
  }
}
