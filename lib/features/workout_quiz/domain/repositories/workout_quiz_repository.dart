import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';

abstract interface class WorkoutQuizRepository {
  Future<Result<bool>> isQuizTodaySubmitted();

  Future<Result<void>> submitQuiz(WorkoutQuizAnswers answers);
}
