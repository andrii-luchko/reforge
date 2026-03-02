import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_subscription.freezed.dart';
part 'user_subscription.g.dart';

@freezed
sealed class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required int id,
    required bool isActive,
    required DateTime expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required Package package,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);
}

@freezed
sealed class Package with _$Package {
  const factory Package({
    required int id,
    required String name,
    required String rcProductId,
    required String rcPackageGroupId,
  }) = _Package;

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);
}
