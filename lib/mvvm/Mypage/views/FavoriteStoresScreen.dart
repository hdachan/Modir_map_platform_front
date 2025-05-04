import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("관심 매장"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
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
          return ListView.builder(
            itemCount: viewModel.likedFeeds.length,
            itemBuilder: (context, index) {
              final feed = viewModel.likedFeeds[index];
              return _buildFeedCard(context, feed, viewModel);
            },
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildFeedCard(BuildContext context, Feed feed, FeedViewModel viewModel) {
    return GestureDetector(
      onTap: () async {
        // 상세 데이터 로드
        await viewModel.loadFeedDetail(feed.feedId);
        if (viewModel.selectedFeed != null) {
          context.go('/community/detail/${feed.feedId}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("게시물을 불러오지 못했습니다.")),
          );
        }
      },
      child: Container(
        height: 146,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFF6F6F6)),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCategoryLabel('관심 매장'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feed.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoText(feed.username),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: const DecorationImage(
                      image: AssetImage('assets/image/cat.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildIconText(Icons.favorite, '좋아요'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: const Color(0xFFE7E7E7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontFamily: 'Pretendard',
          color: Color(0xFF888888),
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'Pretendard',
        color: Color(0xFF888888),
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF888888),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Pretendard',
              color: Color(0xFF888888),
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}