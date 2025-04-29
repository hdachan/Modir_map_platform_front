import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/FeedViewModel.dart';

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
    final viewModel = Provider.of<FeedViewModel>(context, listen: false);
    viewModel.loadFeedDetail(widget.feedId);
  }

  // 수정 다이얼로그 표시
  void _showEditDialog(BuildContext context, FeedViewModel viewModel) {
    final feed = viewModel.selectedFeed;
    if (feed == null) return;

    final titleController = TextEditingController(text: feed.title ?? '');
    final contentController = TextEditingController(text: feed.content ?? '');

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
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
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
              Navigator.pop(context); // 먼저 다이얼로그 닫기
              try {
                await viewModel.deleteFeed(widget.feedId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("삭제 완료")),
                );
                Navigator.pop(context); // 상세 화면 닫기
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
      appBar: AppBar(
        title: const Text("게시글 상세"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final viewModel = Provider.of<FeedViewModel>(context, listen: false);
              _showEditDialog(context, viewModel);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final viewModel = Provider.of<FeedViewModel>(context, listen: false);
              _showDeleteDialog(context, viewModel);
            },
          ),
        ],
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, viewModel, _) {
          final feed = viewModel.selectedFeed;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feed == null || (feed.title == null && feed.content == null)) {
            return const Center(child: Text("게시글을 찾을 수 없습니다."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feed.title ?? "제목 없음",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(feed.content ?? "내용 없음"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        feed.liked ? Icons.favorite : Icons.favorite_border,
                        color: feed.liked ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        viewModel.toggleLike(widget.feedId);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text("${feed.sumLike}명이 좋아합니다"),
                  ],
                ),
                const SizedBox(height: 16),
                Text("작성자: ${feed.username ?? '알 수 없음'}"),
                Text("조회수: ${feed.hits}"),
                Text("작성일: ${feed.createdAt ?? '알 수 없음'}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
