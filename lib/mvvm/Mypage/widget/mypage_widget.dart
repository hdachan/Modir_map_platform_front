import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';





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
              color: Colors.black,
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
                  color: Color(0xFFD9D9D9),
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

///로그인 버튼
class LoginButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  const LoginButton({
    Key? key,
    required this.buttonText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = 328;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: double.infinity,
            height: 68,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: buttonWidth,
                height: 44,
                decoration: ShapeDecoration(
                  color: Color(0xFF05FFF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


///선택 버튼
Widget buildSelectionButtons(
    List<String> labels, int selectedIndex, Function(int) onPressed, BoxConstraints constraints) {
  return Container(
    width: 360,
    height: 48,
    padding: EdgeInsets.only(left: 16, right: 16), // 최상위 패딩 유지
    child: Container(
      width:328,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양옆으로 배치
        children: List.generate(labels.length, (index) {
          return InkWell(
            onTap: () => onPressed(index),
            child: Container(
              width: 146,
              height: 48,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: selectedIndex == index ? Color(0xFF05FFF7) : Color(0xFF888888),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: selectedIndex == index ? Color(0xFF05FFF7) : Color(0xFF888888),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

/// 바텀시트


class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({super.key});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final Map<int, bool> _repliesVisibility = {0: false, 1: false, 2: false};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 댓글 리스트
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 3, // 이미지 기준 3개 댓글
                  itemBuilder: (context, index) {
                    // 예시 데이터 (답글 포함)
                    final comments = [
                      {
                        'username': '7_ouo_6',
                        'content': '놀업음이 나혼산 명품자판.. 담을 돌기',
                        'time': '2시간 전',
                        'replies': [
                          {'username': 'user1', 'content': '멋지네요!', 'time': '1시간 전'},
                          {'username': 'user2', 'content': '동의합니다!', 'time': '30분 전'},
                        ],
                      },
                      {
                        'username': 'geonight',
                        'content':
                        '어느신 가게하시다.. 마우피 커피까지 완벽하네.. 가슴 떨뜨워지는 양상. 이건 아이 되겠다',
                        'time': '3시간 전',
                        'replies': [
                          {'username': 'user3', 'content': '정말 멋져요!', 'time': '2시간 전'},
                          {'username': 'user4', 'content': '추천합니다!', 'time': '1시간 전'},
                          {'username': 'user5', 'content': '좋아요!', 'time': '10분 전'},
                        ],
                      },
                      {
                        'username': 'ackermann_1225',
                        'content': '명품과자 맛깔내 주는 거야 꾸르르르르',
                        'time': '5시간 전',
                        'replies': [],
                      },
                    ];

                    final comment = comments[index];
                    final isRepliesVisible = _repliesVisibility[index] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 프로필 사진
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8), // 원하는 라운드 값
                                child: Container(
                                  width: 32, // CircleAvatar의 radius: 16과 동일한 크기
                                  height: 32,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 닉네임, 시간, 내용
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${comment['username']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          comment['time'] as String,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['content'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        "답글 달기",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // 답글 더보기 (답글이 있는 경우만 표시)
                                    if ((comment['replies'] as List).isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _repliesVisibility[index] = !isRepliesVisible;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              isRepliesVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isRepliesVisible ? "답글 숨기기" : "답글 ${(comment['replies'] as List).length}개 더보기",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 답글 목록
                          if (isRepliesVisible && (comment['replies'] as List).isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 40), // 들여쓰기
                              child: Column(
                                children: (comment['replies'] as List).map<Widget>((reply) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 프로필 사진
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 12),
                                        // 닉네임, 시간, 내용
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "${reply['username']}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    reply['time'] as String,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                reply['content'] as String,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: () {
                                                  // TODO: 답글에 대한 답글 기능이 필요하면 여기 구현
                                                },
                                                child: Text(
                                                  "답글 달기",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                        ],
                      ),
                    );
                  },
                ),
              ),
              // 댓글 입력창
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // 사용자 프로필 사진
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // 원하는 라운드 값
                      child: Container(
                        width: 32, // CircleAvatar의 radius: 16과 동일한 크기
                        height: 32,
                        color: Colors.grey[200],
                        child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 텍스트 입력 필드 (EmailTextField 스타일 적용)
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(), // 필요 시 상태로 관리
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "큐레이션에 댓글 남기기",
                                  hintStyle: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Color(0xFF888888),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // 댓글 전송 로직
                              },
                              child: const Text(
                                "게시",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 키보드 오버레이 방지
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}

