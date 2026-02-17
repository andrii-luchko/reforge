import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum DeviceType {
  @JsonValue('android')
  android,
  @JsonValue('ios')
  ios,
}
