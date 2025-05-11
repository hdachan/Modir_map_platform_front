import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../feed/viewmodels/CommentViewModel.dart';





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
  final int feedId;
  const CustomBottomSheet({super.key, required this.feedId});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final Map<int, bool> _repliesVisibility = {};

  @override
  void initState() {
    super.initState();
    debugPrint('CustomBottomSheet initState: feedId=${widget.feedId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('CustomBottomSheet postFrameCallback: fetching comments for feedId=${widget.feedId}');
      try {
        final viewModel = Provider.of<CommentViewModel>(context, listen: false);
        debugPrint('CommentViewModel retrieved: $viewModel');
        viewModel.resetPagination(); // 바텀시트 열 때 초기화
        viewModel.fetchComments(widget.feedId);
      } catch (e) {
        debugPrint('Error in postFrameCallback: $e');
      }
    });
  }

  // 나머지 build 메서드는 동일
  @override
  Widget build(BuildContext context) {
    debugPrint('CustomBottomSheet building: feedId=${widget.feedId}');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        debugPrint('DraggableScrollableSheet builder called');
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 댓글 목록
              Expanded(
                child: Selector<CommentViewModel, (bool, List<dynamic>, String?, bool)>(
                  selector: (_, vm) => (vm.isLoading, vm.comments, vm.errorMessage, vm.hasMore),
                  builder: (context, data, child) {
                    final (isLoading, comments, errorMessage, hasMore) = data;
                    final viewModel = context.read<CommentViewModel>();

                    if (isLoading && comments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (errorMessage != null && comments.isEmpty) {
                      return Center(child: Text(errorMessage));
                    }
                    if (comments.isEmpty) {
                      return const Center(child: Text("댓글이 없습니다."));
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == comments.length && hasMore) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () => viewModel.fetchComments(widget.feedId),
                                      child: isLoading
                                          ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                          : const Text("댓글 더보기"),
                                    ),
                                  ),
                                );
                              }

                              final comment = comments[index];
                              final commentId = comment['commentId'] as int;
                              final isRepliesVisible = _repliesVisibility[commentId] ?? false;
                              final replies = context.read<CommentViewModel>().replies[commentId] ?? [];

                              return CommentItem(
                                comment: comment,
                                isRepliesVisible: isRepliesVisible,
                                replies: replies,
                                onToggleReplies: () {
                                  setState(() {
                                    _repliesVisibility[commentId] = !isRepliesVisible;
                                    if (isRepliesVisible) {
                                      context.read<CommentViewModel>().replies.remove(commentId);
                                    } else {
                                      viewModel.fetchReplies(commentId);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // 댓글 입력 UI
              Selector<CommentViewModel, (bool, String?)>(
                selector: (_, vm) => (vm.isLoading, vm.errorMessage),
                builder: (context, data, child) {
                  final (isLoading, errorMessage) = data;
                  final viewModel = context.read<CommentViewModel>();
                  debugPrint('Comment input Selector builder');
                  return Column(
                    children: [
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 32,
                                height: 32,
                                color: Colors.grey[200],
                                child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                        controller: viewModel.controller,
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
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        viewModel.postComment(widget.feedId);
                                      },
                                      child: isLoading
                                          ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                          : const Text(
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
                    ],
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}

// CommentItem은 이전 답변과 동일
class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final bool isRepliesVisible;
  final List<dynamic> replies;
  final VoidCallback onToggleReplies;

  const CommentItem({
    super.key,
    required this.comment,
    required this.isRepliesVisible,
    required this.replies,
    required this.onToggleReplies,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 32,
                  height: 32,
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
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
                          comment['createdAt'] as String,
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
                      onTap: () {
                        // TODO: 답글 달기 기능 구현
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
                    if (replies.isNotEmpty || isRepliesVisible) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onToggleReplies,
                        child: Row(
                          children: [
                            Icon(
                              isRepliesVisible
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isRepliesVisible
                                  ? "답글 숨기기"
                                  : "답글 ${replies.length}개 더보기",
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
          if (isRepliesVisible && replies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: replies.map<Widget>((reply) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
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
                                    reply['createdAt'] as String,
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
  }
}
