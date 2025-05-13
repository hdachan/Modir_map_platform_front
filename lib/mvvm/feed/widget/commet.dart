import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/CommentViewModel.dart';

class CustomBottomSheet extends StatefulWidget {
  final int feedId;
  const CustomBottomSheet({super.key, required this.feedId});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<CommentViewModel>(context, listen: false);
      await viewModel.loadCurrentUser();
      viewModel.resetPagination();
      viewModel.fetchComments(widget.feedId, forceFetch: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 1.0,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      snap: true,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(
          children: [
            Expanded(
              child: Selector<CommentViewModel, (List<dynamic>, bool, bool, String?)>(
                selector: (_, vm) => (vm.comments, vm.isLoading, vm.hasMore, vm.errorMessage),
                builder: (context, data, child) {
                  final (comments, isLoading, hasMore, errorMessage) = data;
                  if (isLoading) return const Center(child: CircularProgressIndicator());
                  if (errorMessage != null && comments.isEmpty) return Center(child: Text(errorMessage));
                  if (comments.isEmpty) return const Center(child: Text("댓글이 없습니다."));
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: comments.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == comments.length && hasMore) {
                        return ElevatedButton(
                          onPressed: isLoading ? null : () => context.read<CommentViewModel>().fetchComments(widget.feedId, forceFetch: true),
                          child: isLoading ? const CircularProgressIndicator() : const Text("댓글 더보기"),
                        );
                      }
                      final comment = comments[index];
                      final commentId = comment['commentId'] as int;
                      return Selector<CommentViewModel, (bool, List<dynamic>, String?)>(
                        selector: (_, vm) => (vm.repliesVisibility[commentId] ?? false, vm.replies[commentId] ?? [], vm.currentUserUuid),
                        builder: (context, replyData, child) {
                          final (isRepliesVisible, commentReplies, currentUserUuid) = replyData;
                          final commentUserId = comment['uuid'] ?? comment['userId'] ?? comment['authorId'] ?? comment['creatorId'];
                          final isOwnComment = currentUserUuid != null && currentUserUuid == commentUserId?.toString();
                          print('CommentItem - commentId: $commentId, isOwnComment: $isOwnComment, commentUserId: $commentUserId, currentUserUuid: $currentUserUuid');
                          return CommentItem(
                            key: ValueKey('comment_$commentId'),
                            comment: comment,
                            isRepliesVisible: isRepliesVisible,
                            replies: commentReplies,
                            feedId: widget.feedId,
                            isOwnComment: isOwnComment,
                            onToggleReplies: () {
                              context.read<CommentViewModel>().toggleRepliesVisibility(commentId, !isRepliesVisible);
                              if (!isRepliesVisible && commentReplies.isEmpty) context.read<CommentViewModel>().fetchReplies(commentId, forceFetch: true);
                            },
                            onReplyPosted: () => context.read<CommentViewModel>().toggleRepliesVisibility(commentId, true),
                            onDelete: () => context.read<CommentViewModel>().deleteComment(commentId, widget.feedId),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Selector<CommentViewModel, (bool, String?)>(
              selector: (_, vm) => (vm.isLoading, vm.errorMessage),
              builder: (context, data, child) {
                final (isLoading, errorMessage) = data;
                final viewModel = context.read<CommentViewModel>();
                return Column(
                  children: [
                    if (errorMessage != null) Text(errorMessage, style: const TextStyle(color: Colors.red)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: viewModel.controller, decoration: const InputDecoration(hintText: '댓글 달기...'))),
                          TextButton(
                            onPressed: isLoading ? null : () => viewModel.postComment(widget.feedId),
                            child: isLoading ? const CircularProgressIndicator() : const Text("게시", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final bool isRepliesVisible;
  final List<dynamic> replies;
  final int feedId;
  final bool isOwnComment;
  final VoidCallback onToggleReplies;
  final VoidCallback onReplyPosted;
  final VoidCallback onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.isRepliesVisible,
    required this.replies,
    required this.feedId,
    required this.isOwnComment,
    required this.onToggleReplies,
    required this.onReplyPosted,
    required this.onDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final TextEditingController _replyController = TextEditingController();
  bool _isReplyFieldVisible = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 16, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${widget.comment['username']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(widget.comment['createdAt'] as String, style: const TextStyle(fontSize: 12)),
                        const Spacer(),
                        if (widget.isOwnComment) InkWell(onTap: widget.onDelete, child: const Icon(Icons.delete_outline, size: 16)),
                      ],
                    ),
                    Text(widget.comment['content'] as String),
                    InkWell(
                      onTap: () => setState(() => _isReplyFieldVisible = !_isReplyFieldVisible),
                      child: Text(_isReplyFieldVisible ? "답글 취소" : "답글 달기", style: const TextStyle(fontSize: 12)),
                    ),
                    if (_isReplyFieldVisible) ...[
                      Row(
                        children: [
                          const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: _replyController, decoration: const InputDecoration(hintText: '대댓글 달기...'))),
                          TextButton(
                            onPressed: () async {
                              await context.read<CommentViewModel>().postReply(widget.feedId, widget.comment['commentId'] as int, _replyController.text);
                              setState(() {
                                _replyController.clear();
                                _isReplyFieldVisible = false;
                              });
                              widget.onReplyPosted();
                            },
                            child: const Text("게시"),
                          ),
                        ],
                      ),
                    ],
                    if (widget.replies.isNotEmpty || widget.isRepliesVisible)
                      InkWell(
                        onTap: widget.onToggleReplies,
                        child: Row(
                          children: [
                            Icon(widget.isRepliesVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
                            Text(widget.isRepliesVisible ? "답글 숨기기" : "답글 ${widget.replies.length}개", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isRepliesVisible && widget.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: widget.replies.map<Widget>((reply) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 16, child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("${reply['username']}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Text(reply['createdAt'] as String, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Text(reply['content'] as String),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}