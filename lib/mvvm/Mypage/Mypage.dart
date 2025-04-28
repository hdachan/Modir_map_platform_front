import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ProfileViewModel.dart';



class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  _stateMyPageScreen createState() => _stateMyPageScreen();
}

class _stateMyPageScreen extends State<MyPageScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileViewModel>(context, listen: false).fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Consumer<ProfileViewModel>(
                builder: (context, profileVM, child) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          width: double.infinity,
                          height: 132,
                          padding: EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16),
                          child: Container(
                            width: 328,
                            height: 84,
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(1.00, -0.08),
                                end: Alignment(-1, 0.08),
                                colors: [Color(0xFF242424), Color(0x4C242424)],
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFF3D3D3D),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  width: 236,
                                  height: 48,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 236,
                                        height: 28,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 183,
                                              height: 28,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  profileVM.nicknameController.text.isNotEmpty
                                                      ? profileVM.nicknameController.text
                                                      : '모디랑님',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.40,
                                                    letterSpacing: -0.35,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              width: 45,
                                              height: 28,
                                              padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(width: 1, color: const Color(0xFF05FFF7)),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '수정',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.30,
                                                    letterSpacing: -0.30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        width: 236,
                                        height: 16,
                                        child: Text(
                                          profileVM.selectedGenderIndex == 0
                                              ? '남성'
                                              : (profileVM.selectedGenderIndex == 1 ? '여성' : '미설정'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                            height: 1.30,
                                            letterSpacing: -0.30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )


                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
