import 'package:supabase_flutter/supabase_flutter.dart';

class InformationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Supabase 회원가입 + 유저정보 테이블 저장
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String birthdate,
    required bool gender,
    required String category,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return null;

      await _supabase.from('userinfo').upsert({
        'id': user.id,
        'email': email,
        'username': username,
        'birthdate': birthdate,
        'gender': gender,
        'category': category,
      });

      return user.id;
    } catch (e) {
      throw Exception('회원가입 또는 유저정보 저장 오류: $e');
    }
  }
}
