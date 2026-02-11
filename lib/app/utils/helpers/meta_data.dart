import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta_data.freezed.dart';
part 'meta_data.g.dart';

@freezed
sealed class MetaData with _$MetaData {
  const factory MetaData({
    required PaginationInfo pagination,
  }) = _MetaData;

  factory MetaData.fromJson(Map<String, dynamic> json) => _$MetaDataFromJson(json);
}

@freezed
sealed class PaginationInfo with _$PaginationInfo {
  const factory PaginationInfo({
    required int page,
    required int total,
    required int limit,
    required int pages,
  }) = _PaginationInfo;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => _$PaginationInfoFromJson(json);
}
