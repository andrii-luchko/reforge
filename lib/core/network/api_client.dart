import 'package:dio/dio.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/data/requests/password_reset_confirm_req.dart';
import 'package:reforge/core/auth/data/requests/password_reset_email_req.dart';
import 'package:reforge/core/auth/data/requests/password_reset_validate_token_req.dart';
import 'package:reforge/core/auth/data/requests/refresh_token_request.dart';
import 'package:reforge/core/auth/data/requests/sign_up_request.dart';
import 'package:reforge/core/auth/data/requests/sign_with_provider_request.dart';
import 'package:reforge/core/auth/data/requests/signin_request.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/workout_common/models/complete_set_request.dart';
import 'package:reforge/features/workout_common/models/exercise_session_dto.dart';
import 'package:reforge/features/workout_flow/data/models/program_day.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session.dart';
import 'package:reforge/features/workout_flow/data/models/workout_summary.dart';
import 'package:reforge/features/workout_flow/data/requests/complete_workout_session_request.dart';
import 'package:reforge/features/workout_flow/data/requests/start_workout_session_request.dart';
import 'package:reforge/features/workout_quiz/data/requests/workout_quiz_request.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth endpoints
  @POST('/auth/signin')
  Future<BaseResponse<AuthTokens>> signin(@Body() SignInRequest request);

  @POST('/auth/password-reset/initiate')
  Future<void> initiatePasswordReset(@Body() PasswordResetEmailRequest request);

  @GET('/auth/password-reset/validate')
  Future<void> validatePasswordReset(@Queries() PasswordResetValidateTokenRequest request);

  @POST('/auth/password-reset/confirm')
  Future<void> confirmPasswordReset(@Body() PasswordResetConfirmRequest request);

  @POST('/auth/signup')
  Future<BaseResponse<AuthTokens>> signup(@Body() SignUpRequest request);

  @POST('/auth/provider')
  Future<BaseResponse<AuthTokens>> provider(@Body() SignWithProviderRequest request);

  @POST('/auth/refresh')
  Future<BaseResponse<AuthTokens>> refreshToken(@Body() RefreshTokenRequest request);

  //Quiz
  @POST('/users/profile')
  Future<BaseResponse<void>> updateProfile(@Body() UpdateProfileRequest request);

  //User
  @GET('/users/me')
  Future<BaseResponse<User>> getCurrentUser();

  @DELETE('/users/me')
  Future<BaseResponse<void>> deleteUser();

  @DELETE('/users/{id}')
  Future<BaseResponse<void>> deleteUserById(@Path('id') int id);

  @POST('/auth/logout')
  Future<void> logout();

  //Training session
  @GET('/workout-programs/program-days/{programDayId}')
  Future<BaseResponse<List<ProgramDay>>> getWorkoutByDay(@Path('programDayId') int programDayId);

  //
  @POST('/workout-exercise-set-sessions')
  Future<void> completeSet(@Body() CreateSetSessionRequest request);

  @GET(
    '/workout-exercise-sessions/sessions/{workout_session_id}/program-exercises/{workout_program_exercise_id}/previous',
  )
  Future<BaseResponse<ExerciseSessionDTO?>> getPreviousExercise(
    @Path('workout_session_id') int workoutSessionId,
    @Path('workout_program_exercise_id') int programExerciseId,
  );

  @PATCH(
    '/workout-exercise-sessions/sessions/{workout_session_id}/program-exercises/{workout_program_exercise_id}/exercises/{exercise_id}/notes',
  )
  Future<void> saveExerciseNotes(
    @Path('workout_session_id') int workoutSessionId,
    @Path('workout_program_exercise_id') int programExerciseId,
    @Path('exercise_id') int exerciseId,
    @BodyExtra('note') String note,
  );

  @POST('/workout-sessions')
  Future<BaseResponse<WorkoutSession>> starWorkoutSession(@Body() StartWorkoutSessionRequest request);

  @DELETE('/workout-sessions/{id}')
  Future<BaseResponse<dynamic>> deleteWorkoutSession(@Path('id') int workoutSessionId);

  @PATCH('/workout-sessions/{id}/complete')
  Future<BaseResponse<WorkoutSessionSummary>> completeWorkoutSession(
    @Path('id') int workoutSessionId,
    @Body() CompleteWorkoutSessionRequest request,
  );

  //Training quiz
  @GET('/user-workout-readiness/users/{id}/check')
  Future<BaseResponse<bool>> isQuizTodaySubmitted(@Path('id') int userId);

  @POST('/user-workout-readiness')
  Future<BaseResponse<void>> submitWorkoutQuiz(@Body() WorkoutQuizRequest request);

  //Leaderboard

  // @GET('/user-workout-readiness/users/{id}/check')
  // Future<BaseResponse<bool>> isQuizTodaySubmitted(@Path('id') int userId);

  // Future<BaseResponse<bool>> getImmortalForges(@Path('id') int userId);
}
