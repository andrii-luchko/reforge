// ignore_for_file: avoid_unused_parameters
import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_info.freezed.dart';
part 'system_info.g.dart';

@freezed
sealed class SystemInfo with _$SystemInfo {
  const factory SystemInfo({
    required String appVersion,
    required String buildNumber,
    required String platform,
    String? deviceModel,
    String? osVersion,
  }) = _SystemInfo;

  factory SystemInfo.fromJson(Map<String, dynamic> json) => _$SystemInfoFromJson(json);
}
