import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/training_session/data/models/workout_summary.dart';
import 'package:reforge/features/training_session/domain/enums/tier.dart';

part 'workout_congratulations_content.freezed.dart';

/// Enum to distinguish between different types of congratulations content
enum CongratulationsContentType {
  rankCard,
  achievement,
  defaultSummary,
}

/// Model for rank card content
@freezed
sealed class RankCardContent with _$RankCardContent {
  const factory RankCardContent({
    required TierEnum tier,
    required String faction,
    required int level,
    required double xpProgress,
    required String title, // Unique text for this rank
    required String description, // Unique text for this rank
  }) = _RankCardContent;
}

/// Model for achievement content
@freezed
sealed class AchievementContent with _$AchievementContent {
  const factory AchievementContent({
    required String id,
    required String imageAsset,
    required String title, // Static text
    required String description, // Static text
  }) = _AchievementContent;
}

/// Model for default summary (exp and time)
@freezed
sealed class WorkoutSummaryContent with _$WorkoutSummaryContent {
  const factory WorkoutSummaryContent({
    required int xpEarned,
    required Duration timeSpent,
    int? newLevel,
    double? xpProgress,
  }) = _WorkoutSummaryContent;

  factory WorkoutSummaryContent.fromSessionSummary(WorkoutSessionSummary summary) {
    return WorkoutSummaryContent(
      xpEarned: summary.totalXpEarned,
      timeSpent: Duration(seconds: summary.duration),
    );
  }
}

/// Union type for all congratulations content
@freezed
sealed class WorkoutCongratulationsContent with _$WorkoutCongratulationsContent {
  const factory WorkoutCongratulationsContent.rankCard(RankCardContent content) = RankCardCongratulations;
  const factory WorkoutCongratulationsContent.achievement(AchievementContent content) = AchievementCongratulations;
  const factory WorkoutCongratulationsContent.summary(WorkoutSummaryContent content) = SummaryCongratulations;
}

extension WorkoutCongratulationsContentX on WorkoutCongratulationsContent {
  CongratulationsContentType get type {
    return switch (this) {
      RankCardCongratulations() => CongratulationsContentType.rankCard,
      AchievementCongratulations() => CongratulationsContentType.achievement,
      SummaryCongratulations() => CongratulationsContentType.defaultSummary,
    };
  }
}
