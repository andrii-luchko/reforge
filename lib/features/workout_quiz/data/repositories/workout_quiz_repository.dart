import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';
import 'package:reforge/features/workout_quiz/data/requests/workout_quiz_request.dart';
import 'package:reforge/features/workout_quiz/domain/repositories/workout_quiz_repository.dart';

@Injectable(as: WorkoutQuizRepository)
class WorkoutQuizRepositoryImpl implements WorkoutQuizRepository {
  WorkoutQuizRepositoryImpl(this._apiClient, this._userSessionService);

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  @override
  Future<Result<bool>> isQuizTodaySubmitted() async {
    final userId = _userSessionService.currentUserId;

    if (userId == null) {
      return Result.error(Exception('User not found'));
    }
    try {
      final isSubmitted = await _apiClient.isQuizTodaySubmitted(userId);

      return Result.success(isSubmitted.data);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> submitQuiz(WorkoutQuizAnswers answers) async {
    try {
      final request = WorkoutQuizRequest.fromWorkoutQuizAnswers(answers: answers);

      await _apiClient.submitWorkoutQuiz(request);

      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
