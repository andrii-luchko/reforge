import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/workout_common/models/workout_congratulations_content.dart';

part 'workout_congratulations_state.dart';
part 'workout_congratulations_cubit.freezed.dart';

@injectable
class WorkoutCongratulationsCubit extends Cubit<WorkoutCongratulationsState> {
  WorkoutCongratulationsCubit() : super(const WorkoutCongratulationsState());

  /// Initialize with a list of content items and optional default summary
  void initialize({
    required List<WorkoutCongratulationsContent> contentItems,
    WorkoutSummaryContent? defaultSummary,
  }) {
    emit(
      WorkoutCongratulationsState(
        contentItems: contentItems,
        defaultSummary: defaultSummary,
      ),
    );
  }

  /// Move to the next content item
  void next() {
    if (state.hasNext) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    } else if (state.shouldShowSummary) {
      // Move to summary
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  /// Get the current content item (null if showing summary or complete)
  WorkoutCongratulationsContent? get currentContent => state.currentContent;

  /// Check if there's more content to show
  bool get hasMore => state.hasNext || state.shouldShowSummary;
}
