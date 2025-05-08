import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/login_result.dart';
import 'package:http/http.dart' as http;


class AuthService {
  final supabase = Supabase.instance.client;

  Future<LoginResult> signIn(String email, String password) async {
    email = email.trim();
    password = password.trim();

    if (email.isEmpty || password.isEmpty) {
      return LoginResult(errorMessage: '이메일과 비밀번호를 모두 입력해주세요.');
    }

    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegExp.hasMatch(email)) {
      return LoginResult(errorMessage: '올바른 이메일 형식을 입력해주세요.');
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final jwt = response.session?.accessToken;
      final userId = response.user?.id;

      if (jwt != null && userId != null) {
        final springResponse = await _sendJwtToSpring(jwt);

        return LoginResult(
          jwt: jwt,
          userId: userId,
          springResponse: springResponse,
        );
      } else {
        return LoginResult(errorMessage: '로그인 실패: 사용자 정보를 확인할 수 없습니다.');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('Invalid login credentials')) {
        return LoginResult(errorMessage: '이메일 또는 비밀번호가 잘못되었습니다.');
      }
      return LoginResult(errorMessage: '알 수 없는 오류: $msg');
    }
  }

  Future<String?> _sendJwtToSpring(String jwt) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/user/profile'), // 실제 Spring API
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Spring 오류: ${response.statusCode} - ${response.body}');
        return 'Spring 오류: ${response.statusCode}';
      }
    } catch (e) {
      print('Spring 요청 실패: $e');
      return 'Spring 요청 실패: $e';
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:59172/auth/v1/callback', // 현재 포트로 변경
      );
      print('Google 로그인 완료');
    } catch (e, stack) {
      print('로그인 중 오류 발생: $e');
      print('스택 트레이스: $stack');
      if (e is AuthException) {
        print('AuthException 세부 정보: ${e.message}');
      }
    }
  }




}
