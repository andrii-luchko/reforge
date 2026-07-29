// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/controller/map/running_map_state.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';

@injectable
class RunningMapCubit extends Cubit<RunningMapState> {
  RunningMapCubit(
    this._repository,
    this._serviceClient,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExerciseId,
  ) : super(const RunningMapState());

  final LocalWorkoutSessionRepository _repository;
  final RunningServiceClient _serviceClient;
  final int workoutSessionId;
  final int programExerciseId;

  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<RunningMetrics>? _metricsSub;

  Future<void> init() async {
    try {
      // Load historical points from the repository
      final points = await _repository.getRoutePoints(
        sessionId: workoutSessionId,
        programExerciseId: programExerciseId,
      );
      final lastPoint = points.lastOrNull;

      emit(
        state.copyWith(
          routePoints: points,
          currentLocation: lastPoint,
        ),
      );

      // Subscribe to compass events with 300ms throttle to save battery
      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading != null) {
          final diff = (state.compassHeading - event.heading!).abs();
          final shortestDiff = diff > 180.0 ? 360.0 - diff : diff;

          // Ignore micro hand-shakes less than 2 degrees
          if (shortestDiff > 2.0) {
            emit(state.copyWith(compassHeading: event.heading!));
          }
        }
      });

      // Subscribe to GPS metrics from the background service
      _metricsSub = _serviceClient.metricsStream.listen((metrics) {
        if (metrics.currentLocation != null) {
          emit(
            state.copyWith(
              //   compassHeading: metrics.currentLocation!.heading,
              currentLocation: metrics.currentLocation,
              routePoints: [...state.routePoints, metrics.currentLocation!],
            ),
          );
        }
      });
    } catch (e, st) {
      logger.e('RunningMapCubit: Initialization failed', e, st);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void setFollowingUser(bool isFollowing) {
    emit(state.copyWith(isFollowingUser: isFollowing));
  }

  @override
  Future<void> close() async {
    await _compassSub?.cancel();
    await _metricsSub?.cancel();
    return super.close();
  }
}
