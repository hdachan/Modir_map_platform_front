import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../cofing/SupabaseConfig.dart';
import 'login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase JWT 인증 테스트',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final supabase = Supabase.instance.client;
  String? _errorMessage;
  String? _successMessage;

  // Supabase 회원가입 및 Spring 서버 데이터 전송
  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 입력 유효성 검사
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = '모든 필드를 입력해주세요.';
        _successMessage = null;
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
        _successMessage = null;
      });
      return;
    }

    try {
      // Supabase 회원가입
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      final jwt = response.session?.accessToken;

      if (userId == null || jwt == null) {
        setState(() {
          _errorMessage = '회원가입 실패: 사용자 정보 또는 JWT를 받지 못했습니다.';
          _successMessage = null;
        });
        return;
      }

      print('✅ Supabase 회원가입 성공 - User ID: $userId');

      // Spring 서버로 사용자 정보 전송
      final springResponse = await http.post(
        Uri.parse('http://localhost:8080/api/user'), // URL 수정
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'uuid': userId,
          'email': email,
          'userName': email.split('@')[0], // userName 추가
        }),
      );

      final responseBody = jsonDecode(springResponse.body);

      setState(() {
        if (springResponse.statusCode == 200 && responseBody['resultData'] == 1) {
          _successMessage = '회원가입 완료! 로그인 화면으로 이동하세요.';
          _errorMessage = null;
        } else {
          _errorMessage = 'Spring 서버 등록 실패: ${responseBody['resultMessage']}';
          _successMessage = null;
        }
      });

      print('⬅️ Spring 응답: ${springResponse.statusCode}, ${springResponse.body}');
    } catch (error) {
      setState(() {
        _errorMessage = '오류: $error';
        _successMessage = null;
      });
      print('에러: $error');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('회원가입'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('이미 계정이 있으신가요? 로그인'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}