import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../model/login_result.dart';


class AuthService {
  final supabase = Supabase.instance.client;

  Future<LoginResult> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final jwt = response.session?.accessToken;
      final userId = response.user?.id;

      if (jwt != null && userId != null) {
        return LoginResult(jwt: jwt, userId: userId);
      } else {
        return LoginResult(errorMessage: 'JWT 또는 user_id 발급 실패');
      }
    } catch (error) {
      return LoginResult(errorMessage: '로그인 실패: $error');
    }
  }

  Future<String> signUpTestUser() async {
    const email = 'test@example.com';
    const password = 'StrongPass123!';
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return '테스트 사용자 등록 성공: $email';
    } catch (error) {
      return '테스트 사용자 등록 실패: $error';
    }
  }

  Future<String> sendJwtToSpring(String jwt, {bool isPrivate = false}) async {
    final springServerUrl = isPrivate
        ? 'http://localhost:8080/api/private/hello'
        : 'http://localhost:8080/api/user/profile';

    try {
      final response = await http.get(
        Uri.parse(springServerUrl),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        return '${isPrivate ? "🔐 보호된 API 응답: " : "🌐 공개 API 응답: "}${response.body}';
      } else {
        return '❌ 인증 실패: 상태코드 ${response.statusCode}';
      }
    } catch (error) {
      return 'Spring 서버 요청 실패: $error';
    }
  }
}
