import 'package:flutter/material.dart';
import '../services/FeedCommentService.dart';


class CommentViewModel extends ChangeNotifier {
  final FeedCommentService _commentService;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _comments = [];
  Map<int, List<dynamic>> _replies = {};
  Map<int, bool> _repliesVisibility = {};
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _startIdx = 0;
  final int _pageSize = 3;

  CommentViewModel(this._commentService);

  TextEditingController get controller => _controller;
  List<dynamic> get comments => _comments;
  Map<int, List<dynamic>> get replies => _replies;
  Map<int, bool> get repliesVisibility => _repliesVisibility;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  void resetPagination() {
    debugPrint('resetPagination called');
    _comments = [];
    _startIdx = 0;
    _hasMore = true;
    _errorMessage = null;
    // _replies와 _repliesVisibility는 유지
    notifyListeners();
  }

  Future<void> fetchComments(int feedId, {bool forceFetch = false}) async {
    if (_isLoading && !forceFetch) {
      debugPrint('fetchComments skipped: isLoading=$_isLoading, hasMore=$_hasMore');
      return;
    }
    if (!_hasMore && !forceFetch) {
      debugPrint('fetchComments skipped: no more comments');
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    debugPrint('fetchComments started with feedId: $feedId, startIdx: $_startIdx');
    notifyListeners();
    try {
      final newComments = await _commentService.getComments(feedId, _startIdx, _pageSize);
      debugPrint('Fetched ${newComments.length} comments: $newComments');
      if (newComments.isEmpty) {
        debugPrint('Warning: No comments returned from server');
      }
      if (newComments.length < _pageSize) {
        _hasMore = false;
        debugPrint('No more comments to fetch');
      }
      _comments.addAll(newComments);
      _startIdx += newComments.length;

      // 대댓글 자동 조회
      for (var comment in newComments) {
        final commentId = comment['commentId'] as int;
        if (!_replies.containsKey(commentId)) {
          _replies[commentId] = [];
        }
        debugPrint('Fetching replies for commentId: $commentId');
        await fetchReplies(commentId, forceFetch: true);
        if (_replies[commentId]!.isNotEmpty) {
          _repliesVisibility[commentId] = true;
          debugPrint('Set repliesVisibility[$commentId] = true due to replies: ${_replies[commentId]}');
        } else {
          _repliesVisibility[commentId] = _repliesVisibility[commentId] ?? false;
          debugPrint('No replies for commentId: $commentId, repliesVisibility: ${_repliesVisibility[commentId]}');
        }
      }
      debugPrint('Updated comments: $_comments (length: ${_comments.length}), RepliesVisibility: $_repliesVisibility, Replies: $_replies');
    } catch (e) {
      _errorMessage = "댓글 로드 실패: $e";
      debugPrint('fetchComments Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postComment(int feedId) async {
    if (_controller.text.isEmpty) return;
    debugPrint('postComment called with feedId: $feedId, content: ${_controller.text}');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newCommentId = await _commentService.postComment(_controller.text, feedId);
      debugPrint('New commentId: $newCommentId');
      _controller.clear();
      resetPagination();
      await Future.delayed(Duration(milliseconds: 1000));
      await fetchComments(feedId, forceFetch: true);
      debugPrint('Comments after fetch: $_comments (length: ${_comments.length})');
    } catch (e) {
      _errorMessage = "댓글 등록 실패: $e";
      debugPrint('postComment Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReplies(int commentId, {bool forceFetch = false}) async {
    if (!forceFetch && (_replies[commentId]?.isNotEmpty ?? false)) {
      debugPrint('fetchReplies skipped: replies already loaded for commentId: $commentId');
      return;
    }
    debugPrint('fetchReplies started with commentId: $commentId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final replies = await _commentService.getReplies(commentId);
      debugPrint('Fetched ${replies.length} replies for commentId: $commentId: $replies');
      _replies[commentId] = replies;
      if (replies.isEmpty) {
        debugPrint('Warning: No replies found for commentId: $commentId');
      } else {
        _repliesVisibility[commentId] = true;
        debugPrint('Set repliesVisibility[$commentId] = true due to fetched replies');
      }
    } catch (e) {
      _errorMessage = "대댓글 로드 실패: $e";
      debugPrint('fetchReplies Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postReply(int feedId, int parentCommentId, String content) async {
    if (content.isEmpty) return;
    debugPrint('postReply called with feedId: $feedId, parentCommentId: $parentCommentId, content: $content');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newReplyId = await _commentService.postReply(content, feedId, parentCommentId);
      debugPrint('New replyId: $newReplyId');
      _replies[parentCommentId] = []; // 캐시 초기화
      await fetchReplies(parentCommentId, forceFetch: true); // 대댓글 갱신
      _repliesVisibility[parentCommentId] = true; // 대댓글 표시
      debugPrint('Replies after fetch: ${_replies[parentCommentId]}');
    } catch (e) {
      _errorMessage = "대댓글 등록 실패: $e";
      debugPrint('postReply Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleRepliesVisibility(int commentId, bool isVisible) {
    debugPrint('toggleRepliesVisibility called: commentId=$commentId, isVisible=$isVisible');
    _repliesVisibility[commentId] = isVisible;
    notifyListeners();
    debugPrint('After toggleRepliesVisibility: repliesVisibility=$_repliesVisibility');
  }
}