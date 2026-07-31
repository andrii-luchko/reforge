import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ExecutionMode {
  standard,
  segmented;

  static ExecutionMode fromJson(String json) {
    switch (json) {
      case 'standard':
        return .standard;
      case 'segmented':
        return .segmented;

      default:
        return ExecutionMode.standard;
    }
  }
}
