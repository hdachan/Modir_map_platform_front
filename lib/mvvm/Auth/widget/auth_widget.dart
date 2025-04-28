import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '모디랑',
                  style: const TextStyle(
                    color: Color(0xFF05FFF7),
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                    letterSpacing: -0.60,
                  ),
                ),
                TextSpan(
                  text: '에서 다양한\n매장 정보를 확인하세요',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.30,
                    letterSpacing: -0.60,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          const Text(
            '나만의 분위기 , 라이프스타일 , 스타일링에 따라 매장을 추천받아보세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.40,
              letterSpacing: -0.35,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}


class CustomLoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final Color backgroundColor;
  final Gradient? gradient;
  final BorderSide? borderSide;
  final Color textColor;
  final String fontFamily;
  final double iconSize;
  final VoidCallback? onPressed;

  const CustomLoginButton({
    super.key,
    required this.iconPath,
    required this.label,
    this.backgroundColor = Colors.transparent,
    this.gradient,
    this.borderSide,
    required this.textColor,
    required this.fontFamily,
    this.iconSize = 20,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () => print('버튼 눌렀습니다'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: borderSide ?? BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: iconSize,
              width: iconSize,
            ),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                    height: 1.40,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}