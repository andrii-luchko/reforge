import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum RankStatus {
  completed,
  current,
  locked,
}
