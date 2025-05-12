import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/FeedViewModel.dart';
import '../viewmodels/CommentViewModel.dart';
import '../widget/commet.dart'; // 추가

class FeedDetailScreen extends StatefulWidget {
  final int feedId;

  const FeedDetailScreen({super.key, required this.feedId});

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FeedViewModel>(context, listen: false);
      viewModel.loadFeedDetail(widget.feedId);
    });
  }

  // 수정 다이얼로그 표시
  void _showEditDialog(BuildContext context, FeedViewModel viewModel) {
    final feed = viewModel.selectedFeed;
    if (feed == null) return;

    final titleController = TextEditingController(text: feed.title);
    final contentController = TextEditingController(text: feed.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("게시물 수정"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "내용"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("제목과 내용을 입력하세요")),
                );
                return;
              }

              try {
                await viewModel.updateFeed(
                  widget.feedId,
                  titleController.text,
                  contentController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("게시물이 수정되었습니다")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("수정 실패: $e")),
                );
              }
            },
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }

  // 삭제 다이얼로그 표시
  void _showDeleteDialog(BuildContext context, FeedViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("삭제 확인"),
        content: const Text("정말로 이 게시물을 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 삭제 확인 다이얼로그 닫기
              try {
                await viewModel.deleteFeed(widget.feedId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("삭제 완료")),
                );
                context.go('/community'); // 상세 화면 닫고 커뮤니티 목록으로 이동
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("삭제 실패: $e")),
                );
              }
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: false, // 기본 뒤로가기 제거
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Row(
              children: [
                // 로고
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.chevron_left,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                // 설정 아이콘
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.ios_share,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                // 작성자일 경우에만 메뉴 아이콘 추가
                Consumer<FeedViewModel>(
                  builder: (context, viewModel, _) {
                    final feed = viewModel.selectedFeed;
                    final isAuthor = feed?.isAuthor ?? false;

                    return isAuthor
                        ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, viewModel);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, viewModel);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('수정하기'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('삭제하기'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                    )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, viewModel, _) {
          final feed = viewModel.selectedFeed;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feed == null || (feed.title.isEmpty && feed.content.isEmpty)) {
            return const Center(child: Text("게시글을 찾을 수 없습니다."));
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 64,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: ShapeDecoration(
                              color: Colors.cyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            feed.username,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40,
                                              letterSpacing: -0.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  SizedBox(
                                    height: 16,
                                    child: Row(
                                      children: [
                                        Text(
                                          feed.createdAt,
                                          style: TextStyle(
                                            color: const Color(0xFF888888),
                                            fontSize: 12,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            height: 1.30,
                                            letterSpacing: -0.30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 160,
                        height: 200,
                        padding: EdgeInsets.only(left: 16, right: 16),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFFE7E7E7),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              viewModel.toggleLike(widget.feedId);
                            },
                            child: Icon(
                              feed.liked ? Icons.favorite : Icons.favorite_border,
                              color: feed.liked ? Colors.red : Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${feed.sumLike}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<CommentViewModel>(
                            builder: (context, commentViewModel, _) {
                              return GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (BuildContext context) {
                                      return CustomBottomSheet(feedId:widget.feedId); // feedId 전달
                                    },
                                  );
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Icon(Icons.mode_comment_outlined),
                                    SizedBox(width: 4),
                                    // Text(
                                    //   "${commentViewModel.comments.length}",
                                    //   style: const TextStyle(
                                    //     color: Colors.black,
                                    //     fontSize: 14,
                                    //     fontFamily: 'Pretendard',
                                    //     fontWeight: FontWeight.w400,
                                    //     height: 1.40,
                                    //     letterSpacing: -0.35,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feed.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.20,
                              letterSpacing: -0.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            feed.content,
                            style: const TextStyle(
                              color: Color(0xFF3D3D3D),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.40,
                              letterSpacing: -0.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 12, bottom: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF3D3D3D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          '시작하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
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
            ),
          );
        },
      ),
    );
  }
}