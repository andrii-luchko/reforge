import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/quiz/domain/repositories/quiz_repository.dart';

@Injectable(as: QuizRepository)
class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(this._apiClient, this._localDataSource);

  final ApiClient _apiClient;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<void>> submitQuiz(QuizAnswers answers) async {
    try {
      final request = UpdateProfileRequest.fromQuizAnswers(answers: answers);
      await _apiClient.updateProfile(request);
      await _localDataSource.setQuizFinished();
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
