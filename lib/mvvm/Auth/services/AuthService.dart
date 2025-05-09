import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/login_result.dart';
import 'package:http/http.dart' as http;


class AuthService {
  final supabase = Supabase.instance.client;
  final _emailCache = <String, bool>{};



  Future<bool> validateAndCheckEmail(String email) async {
    email = email.trim().toLowerCase();
    if (email.isEmpty) {
      throw Exception('이메일 주소를 입력하세요.');
    }
    if (email.length > 254) {
      throw Exception('이메일은 254자를 넘을 수 없습니다.');
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) {
      throw Exception('유효한 이메일 주소를 입력하세요.');
    }

    if (_emailCache.containsKey(email)) {
      if (!_emailCache[email]!) {
        throw Exception('이미 등록된 이메일입니다.');
      }
      return true;
    }

    try {
      final response = await Supabase.instance.client
          .from('userinfo')
          .select('id')
          .eq('email', email)
          .maybeSingle()
          .timeout(Duration(seconds: 10));

      final isAvailable = response == null;
      _emailCache[email] = isAvailable;
      if (!isAvailable) {
        throw Exception('이미 등록된 이메일입니다.');
      }
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('네트워크가 느립니다.');
      } else if (e is PostgrestException) {
        throw Exception('서버 오류: ${e.message}');
      } else {
        throw Exception('이메일 확인에 실패했습니다.');
      }
    }
  }



  Future<LoginResult> signIn(String email, String password) async {
    email = email.trim();
    password = password.trim();

    print('[서비스] 입력 받은 이메일: $email');
    print('[서비스] 입력 받은 비밀번호: $password');

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

      print('[서비스] Supabase JWT: $jwt');
      print('[서비스] Supabase User ID: $userId');

      if (jwt != null && userId != null) {
        final rawSpringResponse = await _sendJwtToSpring(jwt);
        final springUuid = rawSpringResponse?.replaceFirst('UUID: ', '');

        print('[서비스] Spring 응답 UUID (가공 전): $rawSpringResponse');
        print('[서비스] Spring 응답 UUID (가공 후): $springUuid');

        if (springUuid == userId) {
          return LoginResult(
            jwt: jwt,
            userId: userId,
            springResponse: springUuid,
          );
        } else {
          return LoginResult(errorMessage: '사용자 정보가 일치하지 않습니다.');
        }
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

  /// 로컬용
  // Future<void> signInWithGoogle() async {
  //   try {
  //     await Supabase.instance.client.auth.signInWithOAuth(
  //       OAuthProvider.google,
  //       redirectTo: 'http://localhost:59172/auth/v1/callback', // 현재 포트로 변경
  //     );
  //     print('Google 로그인 완료');
  //   } catch (e, stack) {
  //     print('로그인 중 오류 발생: $e');
  //     print('스택 트레이스: $stack');
  //     if (e is AuthException) {
  //       print('AuthException 세부 정보: ${e.message}');
  //     }
  //   }
  // }


  /// 서버용
  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://modir-club.web.app/auth/v1/callback', // 배포된 URL로 변경
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
