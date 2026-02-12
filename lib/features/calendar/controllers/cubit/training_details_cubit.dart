import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_details_state.dart';
part 'training_details_cubit.freezed.dart';

class TrainingDetailsCubit extends Cubit<TrainingDetailsState> {
  TrainingDetailsCubit() : super(TrainingDetailsState.initial());
}
