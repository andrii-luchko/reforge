import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/quiz/domain/repositories/quiz_repository.dart';

@Injectable(as: QuizRepository)
class QuizRepositoryImpl with RepositoryErrorHandler implements QuizRepository {
  QuizRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<void>> submitQuiz(QuizAnswers answers) async {
    try {
      final request = UpdateProfileRequest.fromQuizAnswers(answers: answers);
      await makeRequest(
        () => _apiClient.updateProfile(request),
        label: 'submitQuiz',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
