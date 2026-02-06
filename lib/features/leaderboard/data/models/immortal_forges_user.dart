import 'package:freezed_annotation/freezed_annotation.dart';

part 'immortal_forges_user.freezed.dart';
part 'immortal_forges_user.g.dart';

@freezed
sealed class ImmortalForgesUser with _$ImmortalForgesUser {
  const factory ImmortalForgesUser({
    required int userId,
    required int score,
    String? username,
    String? email,
    String? avatarUrl,
  }) = _ImmortalForgesUser;

  factory ImmortalForgesUser.fromJson(Map<String, dynamic> json) => _$ImmortalForgesUserFromJson(json);
}
