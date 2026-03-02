import 'dart:io';

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
import 'package:reforge/features/achievements/data/models/achievement_badge_dto.dart';
import 'package:reforge/features/achievements/data/models/attributes_dto.dart';
import 'package:reforge/features/calendar/data/models/calendar_data.dart';
import 'package:reforge/features/home/data/models/user_stats_dto.dart';
import 'package:reforge/features/leaderboard/data/models/faction_leaderboard_dto.dart';
import 'package:reforge/features/leaderboard/data/response/immortal_forges_response.dart';
import 'package:reforge/features/leaderboard/data/response/leaderboard_users_response.dart';
import 'package:reforge/features/lore/data/models/jiku_plate_dto.dart';
import 'package:reforge/features/lore/data/response/jiku_plates_response.dart';
import 'package:reforge/features/notifications/data/models/notification_model_dto.dart';
import 'package:reforge/features/notifications/data/models/notification_test_request.dart';
import 'package:reforge/features/notifications/data/models/register_tokens_request.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/settings/data/request/profile_requests.dart';
import 'package:reforge/features/workout_common/models/complete_set_request.dart';
import 'package:reforge/features/workout_common/models/exercise_session_dto.dart';
import 'package:reforge/features/workout_flow/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session.dart';
import 'package:reforge/features/workout_flow/data/models/workout_session_details_dto.dart';
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
  @Extra({'requiresAuth': false})
  @POST('/auth/signin')
  Future<BaseResponse<AuthTokens>> signin(@Body() SignInRequest request);

  @Extra({'requiresAuth': false})
  @POST('/auth/password-reset/initiate')
  Future<void> initiatePasswordReset(@Body() PasswordResetEmailRequest request);

  @Extra({'requiresAuth': false})
  @GET('/auth/password-reset/validate')
  Future<void> validatePasswordReset(@Queries() PasswordResetValidateTokenRequest request);

  @Extra({'requiresAuth': false})
  @POST('/auth/password-reset/confirm')
  Future<void> confirmPasswordReset(@Body() PasswordResetConfirmRequest request);

  @Extra({'requiresAuth': false})
  @POST('/auth/signup')
  Future<BaseResponse<AuthTokens>> signup(@Body() SignUpRequest request);

  @Extra({'requiresAuth': false})
  @POST('/auth/provider')
  Future<BaseResponse<AuthTokens>> provider(@Body() SignWithProviderRequest request);

  @Extra({'requiresAuth': false})
  @POST('/auth/refresh')
  Future<BaseResponse<AuthTokens>> refreshToken(
    @Body() RefreshTokenRequest request,
  );

  //Quiz
  @POST('/users/profile')
  Future<BaseResponse<void>> updateProfile(@Body() UpdateProfileRequest request);

  //User
  @GET('/users/me')
  Future<BaseResponse<User>> getCurrentUser();

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateUsername(@BodyExtra('username') String username);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateAvatar(@BodyExtra('avatarUrl') String avatarUrl);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateFactions(@Body() UpdateFactionsRequest request);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateBirthDate(@BodyExtra('birthDate') String birthDate);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateMeasurementSystem(@Body() UpdateMeasurementSystemRequest request);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateWorkoutDays(@Body() UpdateWorkoutDaysRequest request);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateBodyWeight(@BodyExtra('bodyweight') int bodyWeight);

  @PATCH('/users/me')
  Future<BaseResponse<User>> updateNotificationSettings(@Body() UpdateNotificationsRequest request);

  @PATCH('/users/{id}/email')
  Future<BaseResponse<User>> updateCurrentUserEmail(@Path('id') int id, @BodyExtra('email') String email);

  @DELETE('/users/me')
  Future<void> deleteUser();

  @DELETE('/users/{id}')
  Future<BaseResponse<void>> deleteUserById(@Path('id') int id);

  @POST('/auth/logout')
  Future<void> logout();

  //Training session
  @GET('/workout-programs/program-days/{programDayId}')
  Future<BaseResponse<List<ProgramDayDTO>>> getWorkoutByDay(@Path('programDayId') int programDayId);

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

  @GET('/leaderboards/global')
  Future<LeaderboardResponse> getGlobalUserList(@Query('page') int page, @Query('limit') int limit);

  @GET('/leaderboards/factions/local')
  Future<BaseResponse<List<FactionLeaderboardDto>>> getLocalFactionsLeaderboard();

  @GET('/leaderboards/factions/global')
  Future<BaseResponse<List<FactionLeaderboardDto>>> getGlobalFactionsLeaderboard();

  @GET('/leaderboards/forges/factions/{factionName}')
  Future<ImmortalForgesResponse> getImmortalForges(@Path('factionName') String factionName);

  //Achievements

  @GET('/user-forge-experience/progress')
  Future<BaseResponse<List<AttributesDto>>> getUserAttributes();

  @GET('/workout-milestones')
  Future<BaseResponse<List<AchievementBadgeDto>>> getUserBadges();

  //images
  @POST('/supabase/upload')
  @MultiPart()
  Future<BaseResponse<String>> uploadFile({
    @Query('bucket') required String bucket,

    @Part(name: 'file') required File file,
  });

  //Home

  @GET('/workout-sessions/results')
  Future<BaseResponse<UserStatsDataDto>> getUserStats({
    @Query('startDate') required String startDate,
    @Query('endDate') required String endDate,
  });

  //Calendar
  @GET('/workout-sessions/month-calendar')
  Future<BaseResponse<CalendarData>> geMonthCalendar({
    @Query('month') required String month,
  });

  @GET('/workout-sessions/{sessionId}')
  Future<BaseResponse<WorkoutSessionDetailsDTO>> getWorkoutDetails(@Path('sessionId') int sessionId);

  // Lore / Jiku Plates
  @GET('/jiku-plates')
  Future<JikuPlatesResponse> getJikuPlates(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('search') String? search,
  );

  @GET('/jiku-plates/{id}')
  Future<BaseResponse<JikuPlateDetailDto>> getJikuPlateById(@Path('id') int id);

  //notifications
  @GET('/notifications/history')
  Future<BaseResponse<List<NotificationModelDto>>> getNotificationHistory();

  @POST('/notifications/register-token')
  Future<void> registerToken(@Body() RegisterFcmTokensRequestDto request);

  @PATCH('/notifications/{id}/read')
  Future<void> markNotificationAsRead(@Path('id') int id);

  @PATCH('/notifications/read-all')
  Future<void> markAllNotificationsAsRead();

  @POST('/notifications/test')
  Future<BaseResponse<dynamic>> sendNotificationTEST();

  @POST('/notifications/test-custom')
  Future<BaseResponse<dynamic>> sendTestNotification(@Body() NotificationTestRequest request);
}
