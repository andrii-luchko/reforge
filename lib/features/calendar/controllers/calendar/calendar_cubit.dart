import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_state.dart';
part 'calendar_cubit.freezed.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit() : super(const CalendarState());
}
