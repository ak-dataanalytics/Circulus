import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verification_pending_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/feed/screens/create_post_screen.dart';
import '../../features/games/screens/sudoku_screen.dart';
import '../../features/games/screens/quiz_screen.dart';
import '../../features/games/screens/memory_game_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verification-pending',
      builder: (context, state) => const VerificationPendingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/games/sudoku',
      builder: (context, state) => const SudokuScreen(),
    ),
    GoRoute(
      path: '/games/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/games/memory',
      builder: (context, state) => const MemoryGameScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/chat/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] ?? 'Direct Chat';
        return ChatScreen(title: title);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
