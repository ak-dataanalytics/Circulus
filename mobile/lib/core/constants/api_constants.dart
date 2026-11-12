import 'dart:io';

class ApiConstants {
  // Configurable base URL: 10.0.2.2 for Android Emulator, localhost for iOS simulator, or LAN IP for physical device
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Default Android emulator loopback alias to host machine
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://localhost:8000/api/v1';
    }
  }

  // Endpoints
  static const String verifyInvitation = '/auth/verify-invitation';
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  static const String myProfile = '/users/me';
  static const String directory = '/users/directory';

  static const String feed = '/posts/feed';
  static const String createPost = '/posts/';

  static const String communities = '/communities/';
  static const String events = '/events/';

  static const String conversations = '/chat/conversations';
  static const String games = '/games/';
  static const String startSession = '/games/sessions/start';
  static const String finishSession = '/games/sessions/finish';

  static const String dailyLeaderboard = '/leaderboard/daily';
  static const String weeklyLeaderboard = '/leaderboard/weekly';
  static const String lifetimeLeaderboard = '/leaderboard/lifetime';
  static const String podiumHistory = '/leaderboard/podium/history';
  static const String pointsSummary = '/leaderboard/summary';

  static const String notifications = '/notifications/';
}
