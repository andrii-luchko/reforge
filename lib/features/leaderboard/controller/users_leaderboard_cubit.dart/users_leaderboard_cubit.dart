import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';

part 'users_leaderboard_state.dart';
part 'users_leaderboard_cubit.freezed.dart';

typedef _UserLeaderboardProjection = ({
  int id,
  String? username,
  String? avatarUrl,
  String? rank,
  String? japanRank,
  int? currentProgramDayId,
});

@injectable
class UsersLeaderboardCubit extends Cubit<UsersLeaderboardState> {
  UsersLeaderboardCubit(this._repository, this._userCubit) : super(const UsersLeaderboardState()) {
    _lastProjection = _projection(_userCubit.currentOnboardedUser);
    _userSubscription = _userCubit.onboardedUserChanges.listen(_onUserChanged);
    unawaited(loadUsers());
  }
  final LeaderboardRepositoryI _repository;
  final UserCubit _userCubit;
  StreamSubscription<OnboardedUser?>? _userSubscription;
  _UserLeaderboardProjection? _lastProjection;
  int _userRevision = 0;
  int _loadRequestId = 0;

  _UserLeaderboardProjection? _projection(OnboardedUser? user) => user == null
      ? null
      : (
          id: user.id,
          username: user.userName,
          avatarUrl: user.avatarUrl,
          rank: user.rank,
          japanRank: user.japanRank,
          currentProgramDayId: user.currentProgramDayId,
        );

  void _onUserChanged(OnboardedUser? user) {
    final previous = _lastProjection;
    final current = _projection(user);
    if (previous != current) _userRevision++;
    _lastProjection = current;

    if (current == null) {
      emit(const UsersLeaderboardState());
      return;
    }

    if (previous != current) unawaited(loadUsers());
  }

  Future<void> loadUsers() async {
    final revision = _userRevision;
    final requestId = ++_loadRequestId;
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );

    final result = await _repository.getGlobalUserListPaginated(page: 1);
    if (revision != _userRevision || requestId != _loadRequestId) return;

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
    final revision = _userRevision;
    final requestId = _loadRequestId;
    final result = await _repository.getGlobalUserListPaginated(page: nextPage);
    if (revision != _userRevision || requestId != _loadRequestId) return;

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

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
