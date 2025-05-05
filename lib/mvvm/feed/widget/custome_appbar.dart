import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/feed.dart';



PreferredSizeWidget customAppBar() {
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
        // 돋보기 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("돋보기 버튼 클릭"),
            child: const Icon(
              Icons.search_rounded,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
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
        // 저장 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => print("저장 버튼 클릭"),
            child: const Icon(
              Icons.bookmark_border,
              size: 24,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

PreferredSizeWidget customBodyBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        padding: EdgeInsets.only(left: 16,right: 8,top: 16,bottom: 16),
        child: Row(
          children: [
            Text(
              '공지',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '모디랑 커뮤니티 이용수칙 안내',
              style: TextStyle(
                color: const Color(0xFF5D5D5D),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


/// 커뮤니티 형식
// class PostCard extends StatelessWidget {
//   final Feed feed;
//
//   const PostCard({super.key, required this.feed});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         context.go('/community/detail/${feed.feedId}');
//       },
//       child: Container(
//         height: 146,
//         decoration: ShapeDecoration(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             side: BorderSide(
//               width: 1,
//               color: const Color(0xFFF6F6F6),
//             ),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Column(
//           children: [
//             // 상단 카테고리
//             Row(
//               children: [
//                 _buildCategoryLabel('자유게시판'),
//                 _buildCategoryLabel('투표'),
//               ],
//             ),
//             // 글 정보 + 이미지
//             Row(
//               children: [
//                 Container(
//                   height: 68,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Row(
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             feed.title,
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontFamily: 'Pretendard',
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               height: 1.4,
//                             ),
//                           ),
//                           Container(
//                             width: 252,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               feed.content,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontFamily: 'Pretendard',
//                                 color: Color(0xFF3D3D3D),
//                                 fontWeight: FontWeight.w400,
//                                 height: 1.5,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               _buildInfoText(feed.username), // 작성자 표시
//                               const SizedBox(width: 4),
//                               _buildInfoText('·'),
//                               const SizedBox(width: 4),
//                               _buildInfoText(_formatCreatedAt(feed.createdAt)), // 상대 시간 표시
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   width: 68,
//                   height: 68,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     image: const DecorationImage(
//                       image: AssetImage('assets/image/cat.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // 하단 좋아요/댓글/조회수
//             Row(
//               children: [
//                 _buildIconText(Icons.favorite_border, '${feed.likeCount}'),
//                 _buildIconText(Icons.chat_bubble_outline, '218'),
//                 const Spacer(),
//                 _buildIconText(Icons.remove_red_eye_outlined, '${feed.hits}'), // 조회수 표시
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryLabel(String text) {
//     return Container(
//       height: 14,
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//       margin: const EdgeInsets.only(right: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(2),
//         color: const Color(0xFFE7E7E7),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 8,
//           fontFamily: 'Pretendard',
//           color: Color(0xFF888888),
//           fontWeight: FontWeight.w500,
//           height: 1.2,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoText(String text) {
//     return Text(
//       text,
//       textAlign: TextAlign.left,
//       style: const TextStyle(
//         fontSize: 12,
//         fontFamily: 'Pretendard',
//         color: Color(0xFF888888),
//         fontWeight: FontWeight.w400,
//         height: 1.2,
//       ),
//     );
//   }
//
//   Widget _buildIconText(IconData icon, String text) {
//     return Container(
//       height: 22,
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       margin: const EdgeInsets.only(right: 8),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF888888),
//             size: 14,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: const TextStyle(
//               fontSize: 12,
//               fontFamily: 'Pretendard',
//               color: Color(0xFF888888),
//               fontWeight: FontWeight.w400,
//               height: 1.2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // createdAt을 상대 시간 또는 날짜로 포맷팅하는 메서드
//   String _formatCreatedAt(String createdAt) {
//     try {
//       // createdAt을 DateTime으로 파싱 (ISO 8601 형식 가정)
//       final createdDate = DateTime.parse(createdAt);
//       final now = DateTime.now();
//       final difference = now.difference(createdDate);
//
//       // 7일(604800초) 이내인지 확인
//       if (difference.inDays < 7) {
//         if (difference.inMinutes < 1) {
//           return '방금 전';
//         } else if (difference.inMinutes < 60) {
//           return '${difference.inMinutes}분 전';
//         } else if (difference.inHours < 24) {
//           return '${difference.inHours}시간 전';
//         } else {
//           return '${difference.inDays}일 전';
//         }
//       } else {
//         // 7일 이상이면 날짜 형식으로 표시 (예: 2025-04-16)
//         return DateFormat('yyyy-MM-dd').format(createdDate);
//       }
//     } catch (e) {
//       print('createdAt 파싱 오류: $e');
//       return createdAt; // 파싱 실패 시 원래 문자열 반환
//     }
//   }
// }