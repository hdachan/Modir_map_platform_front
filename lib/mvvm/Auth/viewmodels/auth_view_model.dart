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

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await _authService.signIn(email, password);

    if (result.jwt != null && result.userId != null) {
      jwt = result.jwt;
      userId = result.userId;
      errorMessage = null;

      await SessionManager().saveSession(jwt!, userId!);
    } else {
      errorMessage = result.errorMessage;
    }

    notifyListeners();
  }

  Future<void> signUpTestUser() async {
    final result = await _authService.signUpTestUser();
    errorMessage = result;
    notifyListeners();
  }

  Future<void> sendJwtToSpring({bool isPrivate = false}) async {
    if (jwt == null) return;
    final result = await _authService.sendJwtToSpring(jwt!, isPrivate: isPrivate);
    springResponse = result;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
