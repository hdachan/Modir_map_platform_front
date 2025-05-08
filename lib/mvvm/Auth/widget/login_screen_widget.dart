// 상단 앱바 위젯
import 'package:flutter/material.dart';


PreferredSizeWidget loginAppBar(
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
                child: Center(
                  child: Text(
                    '로그인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                      letterSpacing: -0.35,
                    ),
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
                      color: const Color(0xFF3D3D3D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
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
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
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
            color: Colors.black, // 텍스트 색상 검은색
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
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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


// 이메일 입력 필드 위젯
class EmailTextField extends StatefulWidget {
  final TextEditingController controller;

  const EmailTextField({super.key, required this.controller});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: "email@address.com",
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.cancel, size: 24, color: Color(0xFF888888)),
              ),
            ),

        ],
      ),
    );
  }
}
