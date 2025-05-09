import 'package:flutter/material.dart';
import '../services/AuthService.dart';
import '../../../utils/SessionManager.dart';





class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  String? jwt;
  String? userId;
  String? errorMessage;
  String? springResponse;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signIn() async {
    _isLoading = true;
    errorMessage = null;
    springResponse = null;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    print('[뷰모델] 로그인 시도 이메일: $email');

    final result = await _authService.signIn(email, password);

    _isLoading = false;

    final isValidLogin = result.jwt != null &&
        result.userId != null &&
        result.springResponse != null &&
        result.springResponse == result.userId;

    print('[뷰모델] 로그인 결과: '
        'jwt=${result.jwt?.substring(0, 20)}..., '
        'userId=${result.userId}, '
        'springResponse=${result.springResponse}, '
        'isValid=$isValidLogin');

    if (isValidLogin) {
      jwt = result.jwt;
      userId = result.userId;
      springResponse = result.springResponse;
      await SessionManager().saveSession(jwt!, userId!);
    } else {
      await SessionManager().clearSession();
      errorMessage = result.errorMessage ?? '로그인에 실패했습니다. 사용자 정보를 확인해주세요.';
      print('[뷰모델] 오류 메시지: $errorMessage');
    }

    notifyListeners();
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  Future<bool> validateAndCheckEmail(String email) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.validateAndCheckEmail(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

}
