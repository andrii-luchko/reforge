import 'package:freezed_annotation/freezed_annotation.dart';

part 'tier.freezed.dart';

part 'tier.g.dart';

@freezed
sealed class Tier with _$Tier {
  const Tier._();

  const factory Tier({
    required String title,
    required String description,
    required int rank,
  }) = _Tier;

  factory Tier.fromJson(Map<String, dynamic> json) => _$TierFromJson(json);
}

final List<Tier> mockTiers = [
  const Tier(
    title: 'Beginner',
    description: 'The start of the journey. Mastering the basics.',
    rank: 1,
  ),
  const Tier(
    title: 'Novice',
    description: 'You are settling in, but there is still work to do.',
    rank: 2,
  ),
  const Tier(
    title: 'Intermediate',
    description: 'The golden mean. Consistent results and solid understanding.',
    rank: 3,
  ),
  const Tier(
    title: 'Advanced',
    description: 'High level of mastery. Complex challenges are within reach.',
    rank: 4,
  ),
  const Tier(
    title: 'Elite',
    description: 'The elite. Access to exclusive opportunities and rare rewards.',
    rank: 5,
  ),
  const Tier(
    title: 'Faction Leader',
    description: 'The apex of the hierarchy. You lead the pack.',
    rank: 6,
  ),
];
