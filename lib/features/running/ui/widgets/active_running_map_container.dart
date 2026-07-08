import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/running/controller/map/running_map_cubit.dart';
import 'package:reforge/features/running/controller/map/running_map_state.dart';
import 'package:reforge/features/running/ui/widgets/running_map_view.dart';

class ActiveRunningMapContainer extends StatelessWidget {
  const ActiveRunningMapContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunningMapCubit, RunningMapState>(
      builder: (context, state) {
        return RunningMapView(
          routeMap: state.routePoints,
          currentLocation: state.currentLocation,
          heading: state.compassHeading,
          isFollowingUser: state.isFollowingUser,
          onCameraMoveStarted: () {
            if (state.isFollowingUser) {
              context.read<RunningMapCubit>().setFollowingUser(false);
            }
          },
          onRecenterPressed: () {
            context.read<RunningMapCubit>().setFollowingUser(true);
          },
        );
      },
    );
  }
}
