import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  static const _jwtKey = 'jwt_key';
  static const _userIdKey = 'user_id_key';

  void initializeAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        final jwt = session?.accessToken;
        final userId = session?.user?.id;
        if (jwt != null && userId != null) {
          await saveSession(jwt, userId);
          debugPrint('✅ JWT 저장됨: $jwt');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        await clearSession();
        debugPrint('🚪 로그아웃됨, 세션 삭제됨');
      }
    });
  }

  Future<void> saveSession(String jwt, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, jwt);
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isAuthenticated() async {
    final jwt = await getJwt();
    if (jwt == null) {
      debugPrint('⚠️ JWT 없음');
      return false;
    }

    try {
      final response = await Supabase.instance.client.auth.getUser(jwt);
      final isValid = response.user != null;
      debugPrint('🔐 세션 유효성: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('⚠️ 세션 확인 오류: $e');
      return false;
    }
  }

  Future<String?> getJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'jwt': prefs.getString(_jwtKey),
      'userId': prefs.getString(_userIdKey),
    };
  }
}