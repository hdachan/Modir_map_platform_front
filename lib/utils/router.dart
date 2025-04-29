import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modir/utils/SessionManager.dart';
import 'package:modir/utils/session.dart';
import '../mvvm/Mypage/views/Mypage.dart';
import '../map_screen.dart';
import '../mvvm/Auth/views/auth_selection_screen.dart';
import '../mvvm/feed/views/FeedDetailScreen.dart';
import 'bottom_nav_screen.dart';
import '../mvvm/feed/views/FeedScreen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth_check',
  debugLogDiagnostics: true, // 디버그 로그 활성화
  routes: [
    GoRoute(
      path: '/auth_check',
      builder: (context, state) => const AuthCheckScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginSelectionScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => BottomNavScreen(child: child),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const FeedScreen(),
          routes: [
            GoRoute(
              path: 'detail/:feedId', // feedId를 경로 파라미터로 정의
              builder: (context, state) {
                final feedId = int.parse(state.pathParameters['feedId']!);
                return FeedDetailScreen(feedId: feedId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/mypage',
          builder: (context, state) => const MyPageScreen(),
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final sessionManager = SessionManager();
    final isAuthenticated = await sessionManager.isAuthenticated();
    final path = state.uri.toString();

    debugPrint('🚦 리디렉션: path=$path, isAuthenticated=$isAuthenticated');

    if (!isAuthenticated && (path == '/map' || path == '/community' || path == '/mypage')) {
      return '/login';
    }
    if (isAuthenticated && path == '/login') {
      return '/community';
    }
    return null;
  },
);