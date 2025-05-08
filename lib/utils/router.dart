import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modir/utils/SessionManager.dart';
import 'package:modir/utils/session.dart';

import '../mvvm/Auth/views/SignUpPage.dart';
import '../mvvm/Auth/views/agree_screen.dart';
import '../mvvm/Auth/views/auth_selection_screen.dart';
import '../mvvm/Mypage/views/FavoriteStoresScreen.dart';
import '../mvvm/Mypage/views/Mypage.dart';
import '../mvvm/Mypage/views/SettingScreen.dart';
import '../mvvm/Mypage/views/WithdrawalScreen.dart';
import '../mvvm/Mypage/views/terms.dart';
import '../mvvm/feed/views/WriteScreen.dart';
import '../mvvm/feed/views/FeedDetailScreen.dart';
import '../mvvm/feed/views/modiChat.dart';
import 'bottom_nav_screen.dart';
import '../mvvm/feed/views/FeedScreen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth_check',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/auth_check',
      builder: (context, state) => const AuthCheckScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginSelectionScreen(),
      routes: [
        GoRoute(
          path: 'agree',
          builder: (context, state) => const AgreePage(),
          routes: [
            GoRoute(
              path: 'signup',
              builder: (context, state) => const SignUpPage(),
            ),
          ],
        ),
      ],
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
              path: 'detail/:feedId',
              builder: (context, state) {
                final feedId = int.parse(state.pathParameters['feedId']!);
                return FeedDetailScreen(feedId: feedId);
              },
            ),
            GoRoute(
              path: 'write',
              builder: (context, state) => const WriteFeedScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/mypage',
          builder: (context, state) => MyPageScreen(),
          routes: [
            GoRoute(
              path: 'setting',
              builder: (context, state) => SettingScreen(),
              routes: [
                GoRoute(
                  path: 'withdrawal_reason',
                  pageBuilder: (context, state) => MaterialPage(child: WithdrawalScreen()),
                ),
                GoRoute(
                  path: 'terms',
                  pageBuilder: (context, state) => MaterialPage(child: termsScreen()),
                ),
              ],
            ),
            GoRoute(
              path: 'LikedFeed',
              pageBuilder: (context, state) => MaterialPage(child: LikedFeedScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final sessionManager = SessionManager();
    final isAuthenticated = await sessionManager.isAuthenticated();
    final path = state.uri.toString();

    debugPrint('🚦 리디렉션: path=$path, isAuthenticated=$isAuthenticated');

    // 보호된 경로 목록
    final protectedPrefixes = [
      '/map',
      '/community',
      '/mypage',
    ];

    final isProtected = protectedPrefixes.any((prefix) =>
    path == prefix || path.startsWith('$prefix/'));

    // 비로그인 시 보호된 경로 접근 → 로그인 페이지로
    if (!isAuthenticated && isProtected) {
      return '/login';
    }

    // 로그인된 사용자가 로그인 페이지 접근 → 커뮤니티로 리디렉션
    if (isAuthenticated && path == '/login') {
      return '/community';
    }

    return null;
  },
);
