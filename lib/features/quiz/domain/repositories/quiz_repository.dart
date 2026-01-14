import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';

// ignore: one_member_abstracts
abstract interface class QuizRepository {
  Future<Result<void>> submitQuiz(QuizAnswers answers);
}
