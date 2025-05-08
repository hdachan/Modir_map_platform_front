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

    final result = await _authService.signIn(email, password);

    _isLoading = false;

    if (result.jwt != null && result.userId != null) {
      jwt = result.jwt;
      userId = result.userId;
      springResponse = result.springResponse;
      await SessionManager().saveSession(jwt!, userId!);
    } else {
      errorMessage = result.errorMessage ?? '로그인에 실패했습니다.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
