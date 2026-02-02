import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'leaderboard_state.dart';
part 'leaderboard_cubit.freezed.dart';

@injectable
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit() : super(const LeaderboardState()) {
    loadUsers(Faction.gakki);
  }

  Future<void> loadUsers(Faction faction, {bool forceRefresh = false}) async {
    if (!forceRefresh && state.usersCache.containsKey(faction)) {
      emit(
        state.copyWith(
          selectedFaction: faction,
          status: LeaderboardStatus.success,
        ),
      );
      _updateCurrentUser(state.usersCache[faction]!);
      return;
    }

    emit(
      state.copyWith(
        selectedFaction: faction,
        status: LeaderboardStatus.loading,
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Заменить на реальный вызов репозитория
      // final newUsers = await _repository.getLeaderboard(faction);
      final newUsers = generateMockUsers();

      final updatedCache = Map<Faction, List<LeaderboardUserModel>>.from(state.usersCache);
      updatedCache[faction] = newUsers;

      emit(
        state.copyWith(
          status: LeaderboardStatus.success,
          usersCache: updatedCache,
        ),
      );

      _updateCurrentUser(newUsers);
    } catch (e) {
      emit(state.copyWith(status: LeaderboardStatus.error));
    }
  }

  void changeMode(LeaderboardMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void _updateCurrentUser(List<LeaderboardUserModel> users) {
    LeaderboardUserModel? me;
    int? index;

    if (users.length > 25) {
      index = 25;
      me = users[index];
    }

    emit(
      state.copyWith(
        currentUser: me,
        currentUserIndex: index,
      ),
    );
  }
}
