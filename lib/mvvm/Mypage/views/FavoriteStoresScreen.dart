import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Auth/widget/login_screen_widget.dart';
import '../../feed/models/feed.dart';
import '../../feed/viewmodels/FeedViewModel.dart';

class LikedFeedScreen extends StatefulWidget {
  const LikedFeedScreen({super.key});

  @override
  State<LikedFeedScreen> createState() => _LikedFeedScreenState();
}

class _LikedFeedScreenState extends State<LikedFeedScreen> {
  late Future<void> _likedFeedsFuture;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<FeedViewModel>(context, listen: false);
    _likedFeedsFuture = viewModel.loadLikedFeeds();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeedViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: emailAppBar(
        context,
        "관심 큐레이션",
        const Color(0xFF000000),
            () => print('완료 버튼 눌림'),
      ),
      body: FutureBuilder(
        future: _likedFeedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }
          if (viewModel.likedFeeds.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: Color(0xFF888888),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "관심 피드가 없습니다.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "좋아요한 매장을 추가해보세요!",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: screenWidth > 600 ? 0.6 : 0.55,
                ),
                itemCount: viewModel.likedFeeds.length,
                itemBuilder: (context, index) {
                  final feed = viewModel.likedFeeds[index];
                  return Card2(feed: feed);
                },
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

// Card2 위젯 (FeedScreen에서 그대로 가져  FeedScreen의 Card2를 재사용
class Card2 extends StatelessWidget {
  final Feed feed;

  const Card2({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 360;
    final fontSizeTitle = isSmallScreen ? 11.0 : 12.0;
    final fontSizeContent = isSmallScreen ? 13.0 : 14.0;
    final fontSizeFooter = isSmallScreen ? 11.0 : 12.0;
    final imageHeight = isSmallScreen ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () {
        final viewModel = Provider.of<FeedViewModel>(context, listen: false);
        viewModel.loadFeedDetail(feed.feedId).then((_) {
          if (viewModel.selectedFeed != null) {
            context.go('/community/detail/${feed.feedId}');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("게시물을 불러오지 못했습니다.")),
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
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
                    child: Text(
                      '관심 매장', // FeedScreen의 '광고' 대신 '관심 매장'으로 변경
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
              height: 40,
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
                    size: 12,
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