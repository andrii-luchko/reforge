import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';

part 'users_leaderboard_state.dart';
part 'users_leaderboard_cubit.freezed.dart';

@injectable
class UsersLeaderboardCubit extends Cubit<UsersLeaderboardState> {
  UsersLeaderboardCubit(this._repository) : super(const UsersLeaderboardState()) {
    unawaited(loadUsers());
  }
  final LeaderboardRepositoryI _repository;

  Future<void> loadUsers() async {
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );

    final result = await _repository.getGlobalUserListPaginated(page: 1);

    switch (result) {
      case Success(value: final data):
        emit(
          state.copyWith(
            isLoading: false,
            currentUsersList: data.usersList,
            currentUser: data.currentUser,

            hasReachedMax: 1 >= data.totalPages,
          ),
        );
      case Failure(error: final e):
        emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isPaginationLoading || state.hasReachedMax) return;

    emit(state.copyWith(isPaginationLoading: true, paginationError: null));

    final nextPage = state.currentPage + 1;
    final result = await _repository.getGlobalUserListPaginated(page: nextPage);

    switch (result) {
      case Success(value: final data):
        logger.d('''
$nextPage
${data.totalPages}''');
        emit(
          state.copyWith(
            isPaginationLoading: false,
            paginationError: null,
            currentUsersList: [...state.currentUsersList, ...data.usersList],
            currentPage: nextPage,
            hasReachedMax: nextPage >= data.totalPages,
            currentUser: data.currentUser,
          ),
        );
      case Failure(error: final e):
        emit(state.copyWith(isPaginationLoading: false, paginationError: e.toString()));
    }
  }
}
