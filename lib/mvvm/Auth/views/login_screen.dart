import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

// 로그인 페이지 위젯
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = true; // 자동 로그인 체크 상태

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context); // AuthViewModel 제공

    return Scaffold(
      appBar: customAppBar(
        context,
        "로그인",
        const Color(0xFF000000),
            () => print('완료 버튼 눌림'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      // 이메일 입력 필드
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: viewModel.emailController,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                          decoration: const InputDecoration(
                            hintText: "email@address.com",
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Color(0xFF888888),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 비밀번호 입력 필드
                      PasswordField(controller: viewModel.passwordController),
                    ],
                  ),
                ),
                // 자동 로그인 및 계정 찾기 옵션
                SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isChecked = !isChecked; // 체크 상태 토글
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              isChecked
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 24,
                              color: isChecked
                                  ? const Color(0xFF000000)
                                  : const Color(0xFF242424),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '자동 로그인',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isChecked
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("아이디 찾기");
                            },
                            child: const Text(
                              '아이디 찾기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              print("비밀번호 찾기");
                            },
                            child: const Text(
                              '비밀번호 찾기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 에러 메시지 표시
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: viewModel.errorMessage!.contains('성공')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                // JWT 표시
                if (viewModel.jwt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      '✅ JWT: ${viewModel.jwt!.substring(0, 20)}...',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.green,
                      ),
                    ),
                  ),
                // Spring 응답 표시
                if (viewModel.springResponse != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      viewModel.springResponse!,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: viewModel.springResponse!.contains("응답")
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(
        onLogin: () async {
          await viewModel.signIn(); // 로그인 시도
          if (viewModel.jwt != null) {
            context.go('/community'); // 성공 시 커뮤니티 페이지로 이동
          }
        },
      ),
      backgroundColor: const Color(0xFFFFFFFF), // 배경색 흰색
    );
  }
}

// 상단 앱바 위젯
PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed,
    ) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFFFFFFF), // 배경색 흰색
      elevation: 0,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context), // 뒤로가기 기능 추가
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF000000), // 아이콘 색상 검은색
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF000000), // 텍스트 색상 검은색
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset('assets/image/logo_primary2.png'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 하단 바 위젯
Widget bottomBar({required VoidCallback onLogin}) {
  return Container(
    height: 68,
    color: const Color(0xFFFFFFFF), // 배경색 흰색
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF05FFF7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 비밀번호 입력 필드 위젯
class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true; // 비밀번호 가림 상태

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Center(
        child: TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000), // 텍스트 색상 검은색
          ),
          decoration: InputDecoration(
            hintText: "password",
            hintStyle: const TextStyle(
              fontFamily: 'Pretendard',
              color: Color(0xFF888888),
            ),
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF888888),
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText; // 비밀번호 표시 토글
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}