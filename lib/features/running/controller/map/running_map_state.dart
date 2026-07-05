import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';

part 'running_map_state.freezed.dart';

@freezed
sealed class RunningMapState with _$RunningMapState {
  const RunningMapState._();

  const factory RunningMapState({
    @Default([]) List<RouteCoordinate> routePoints,
    @Default(0.0) double compassHeading,
    RouteCoordinate? currentLocation,
    @Default(true) bool isFollowingUser,
  }) = _RunningMapState;
}
