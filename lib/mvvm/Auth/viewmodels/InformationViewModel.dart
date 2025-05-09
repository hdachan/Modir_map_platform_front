import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/InformationService.dart';
import 'package:http/http.dart' as http;

class InformationViewModel extends ChangeNotifier {
  final InformationService _authService = InformationService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isTextFieldEmpty = true;
  bool _isTextFieldEmpty1 = true;
  int _selectedGenderIndex = -1;
  int _selectedCategoryIndex = -1;
  bool _isNicknameAvailable = true; // 닉네임 사용 가능 여부
  String? _nicknameErrorMessage; // 닉네임 에러 메시지
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  bool get isNicknameEmpty => _isTextFieldEmpty;
  bool get isBirthdateEmpty => _isTextFieldEmpty1;
  int get selectedGenderIndex => _selectedGenderIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isNicknameAvailable => _isNicknameAvailable;
  String? get nicknameErrorMessage => _nicknameErrorMessage;
  TextEditingController get nicknameController => _nicknameController;
  TextEditingController get birthdateController => _birthdateController;

  InformationViewModel() {
    _nicknameController.addListener(() {
      _isTextFieldEmpty = _nicknameController.text.isEmpty;
      // 실시간 닉네임 중복 확인
      _checkNicknameAvailability(_nicknameController.text.trim());
      notifyListeners();
    });
    _birthdateController.addListener(() {
      _isTextFieldEmpty1 = _birthdateController.text.isEmpty;
      notifyListeners();
    });
  }

  // 닉네임 중복 확인 메서드
  Future<void> _checkNicknameAvailability(String nickname) async {
    if (nickname.isEmpty) {
      _isNicknameAvailable = true;
      _nicknameErrorMessage = null;
      notifyListeners();
      return;
    }

    try {
      final response = await _supabase
          .from('userinfo')
          .select('username')
          .eq('username', nickname)
          .maybeSingle();

      if (response != null) {
        _isNicknameAvailable = false;
        _nicknameErrorMessage = '이미 사용 중인 닉네임입니다.';
      } else {
        _isNicknameAvailable = true;
        _nicknameErrorMessage = null;
      }
    } catch (e) {
      _isNicknameAvailable = false;
      _nicknameErrorMessage = '닉네임 확인 중 오류 발생: $e';
    }
    notifyListeners();
  }

  void onGenderButtonPressed(int index) {
    _selectedGenderIndex = index;
    notifyListeners();
  }

  void onCategoryButtonPressed(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  bool _isValidBirthdateFormat(String birthdate) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthdate)) return false;

    final year = int.tryParse(birthdate.substring(0, 4)) ?? 0;
    final month = int.tryParse(birthdate.substring(5, 7)) ?? 0;
    final day = int.tryParse(birthdate.substring(8, 10)) ?? 0;

    if (year < 1900 || year > DateTime.now().year) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    return true;
  }

  Future<String?> signUp(String email, String password) async {
    if (_nicknameController.text.trim().isEmpty) return '닉네임을 입력해주세요.';
    if (_birthdateController.text.trim().isEmpty) return '생년월일을 입력해주세요.';
    if (!_isValidBirthdateFormat(_birthdateController.text.trim())) {
      return '올바른 생년월일 형식(YYYY-MM-DD)으로 입력해주세요.';
    }
    if (_selectedGenderIndex == -1) return '성별을 선택해주세요.';
    if (_selectedCategoryIndex == -1) return '카테고리를 선택해주세요.';
    if (!_isNicknameAvailable) return '이미 사용 중인 닉네임입니다.';

    try {
      final userId = await _authService.signUp(
        email: email,
        password: password,
        username: _nicknameController.text.trim(),
        birthdate: _birthdateController.text.trim(),
        gender: _selectedGenderIndex == 0,
        category: _selectedCategoryIndex == 0 ? '빈티지' : '아메카지',
      );

      if (userId == null) {
        return 'Supabase 회원가입 실패';
      }

      final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
      if (jwt == null) return 'JWT 토큰을 가져오지 못했습니다.';

      // 🔁 Spring 서버로 전달
      final springResponse = await http.post(
        Uri.parse('http://localhost:8080/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'uuid': userId,
          'email': email,
          'userName': _nicknameController.text.trim(),
          'birthdate': _birthdateController.text.trim(),
          'gender': _selectedGenderIndex == 0 ? 'MALE' : 'FEMALE',
          'category': _selectedCategoryIndex == 0 ? '빈티지' : '아메카지',
        }),
      );

      final responseBody = jsonDecode(springResponse.body);

      if (springResponse.statusCode == 200 && responseBody['resultData'] == 1) {
        return null;
      } else {
        return 'Spring 서버 등록 실패: ${responseBody['resultMessage']}';
      }
    } catch (e) {
      return '오류 발생: $e';
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }
}