import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';
import 'package:reforge/features/workout_quiz/domain/repositories/workout_quiz_repository.dart';

class TestWorkoutQuizRepository implements WorkoutQuizRepository {
  const TestWorkoutQuizRepository();

  static bool _isSubmitted = true;

  @override
  Future<Result<bool>> isQuizTodaySubmitted() async {
    return Result.success(_isSubmitted);
  }

  @override
  Future<Result<void>> submitQuiz(WorkoutQuizAnswers answers) async {
    _isSubmitted = true;
    return const Result.success(null);
  }

  static void reset() {
    _isSubmitted = false;
  }
}
