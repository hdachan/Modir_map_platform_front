import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// 마이페이지 상단바
PreferredSizeWidget custommypageAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: Row(
      children: [
        // SVG 이미지 아이콘
        GestureDetector(
          onTap: () => print("로고 클릭"), // 뒤로가기 대신 로고 클릭 동작
          child: Container(
            padding: const EdgeInsets.all(16), // 기존 패딩 유지
            child: SvgPicture.asset(
              'assets/image/logo_primary.svg',
              width: 24, // 아이콘 크기와 일치
              height: 24,
              fit: BoxFit.contain, // 원본 비율 유지
            ),
          ),
        ),
        const Spacer(),
        // 종 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("종 버튼 클릭"),
            child: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
        // 설정아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("저장 버튼 클릭"),
            child: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}


// 마이페이지 중간 텍스트
Widget middleText(String text) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
        child: Container(
          height: 28,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.40,
              letterSpacing: -0.50,
            ),
          ),
        ),
      );
    },
  );
}

// 마이페이지 > 버튼
Widget customButton(String title, VoidCallback onPressed) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, top: 14, bottom: 14),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.arrow_forward_ios_sharp,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}