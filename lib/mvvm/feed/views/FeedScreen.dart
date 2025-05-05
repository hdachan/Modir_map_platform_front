import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widget/custome_appbar.dart';
import '../models/feed.dart';
import '../viewmodels/FeedViewModel.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    final feedVM = Provider.of<FeedViewModel>(context, listen: false);
    feedVM.fetchFeeds();
  }

  @override
  Widget build(BuildContext context) {
    // 화면 너비 가져오기
    final screenWidth = MediaQuery.of(context).size.width;

    // 열 수 결정: 600px 이상이면 3열, 아니면 2열
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Scaffold(
          body: Column(
            children: [
              customAppBar(),
              customBodyBar(context, "공지"),
              Expanded(
                child: Consumer<FeedViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: screenWidth > 600 ? 0.6 : 0.55, // 좁은 화면에서 세로 길이 증가
                      ),
                      itemCount: viewModel.feeds.length,
                      itemBuilder: (context, index) {
                        Feed feed = viewModel.feeds[index];
                        return Card2(feed: feed);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.go('/community/write');
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.edit, color: Colors.white),
            tooltip: '글쓰기',
          ),
        ),
      ),
    );
  }
}

class Card2 extends StatelessWidget {
  final Feed feed;

  const Card2({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    // 화면 너비에 따라 폰트 크기와 이미지 크기 조정
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 360;
    final fontSizeTitle = isSmallScreen ? 11.0 : 12.0;
    final fontSizeContent = isSmallScreen ? 13.0 : 14.0;
    final fontSizeFooter = isSmallScreen ? 11.0 : 12.0;
    final imageHeight = isSmallScreen ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () {
        context.go('/community/detail/${feed.feedId}');
      },
      child: Container(
        padding: const EdgeInsets.all(6), // 패딩 축소
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF6F6F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      feed.username,
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E7E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child:         Text(
                      '광고',
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 8,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -0.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: imageHeight,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/image/cat.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 40, // 내용 높이 축소
              child: Text(
                feed.content,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: fontSizeContent,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatCreatedAt(feed.createdAt),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: fontSizeFooter,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF888888),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.visibility_outlined,
                    color: Color(0xFF888888),
                    size: 12, // 아이콘 크기 축소
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${feed.hits}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: fontSizeFooter,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreatedAt(String createdAt) {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);

      if (difference.inDays < 7) {
        if (difference.inMinutes < 1) {
          return '방금 전';
        } else if (difference.inMinutes < 60) {
          return '${difference.inMinutes}분 전';
        } else if (difference.inHours < 24) {
          return '${difference.inHours}시간 전';
        } else {
          return '${difference.inDays}일 전';
        }
      } else {
        return DateFormat('yyyy-MM-dd').format(createdDate);
      }
    } catch (e) {
      print('createdAt 파싱 오류: $e');
      return createdAt;
    }
  }
}