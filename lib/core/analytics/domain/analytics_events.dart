/// Constants for analytics event names.
abstract final class AnalyticsEvents {
  const AnalyticsEvents._();

  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String subscriptionView = 'subscription_view';
  static const String subscriptionManageClick = 'subscription_manage_click';
  static const String workoutStart = 'workout_start';
  static const String workoutComplete = 'workout_complete';
  static const String quizStart = 'quiz_start';
  static const String quizComplete = 'quiz_complete';
  static const String homeView = 'home_view';
  static const String homeStartWorkoutClick = 'home_start_workout_click';
  static const String homeStatsPeriodChange = 'home_stats_period_change';
  static const String calendarView = 'calendar_view';
  static const String calendarTrainingDetailsClick = 'calendar_training_details_click';
  static const String calendarMonthChange = 'calendar_month_change';
  static const String calendarRefresh = 'calendar_refresh';
  static const String trainingDetailsView = 'training_details_view';
  static const String trainingDetailsRefresh = 'training_details_refresh';
  static const String notificationsView = 'notifications_view';
  static const String notificationsRefresh = 'notifications_refresh';
  static const String notificationsClearOne = 'notifications_clear_one';
  static const String notificationsClearAll = 'notifications_clear_all';
}
