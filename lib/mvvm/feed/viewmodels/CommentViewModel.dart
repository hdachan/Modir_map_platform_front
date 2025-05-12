import 'package:flutter/material.dart';
import '../services/FeedCommentService.dart';

class CommentViewModel extends ChangeNotifier {
  final FeedCommentService _commentService;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _comments = [];
  Map<int, List<dynamic>> _replies = {};
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _startIdx = 0;
  final int _pageSize = 5;

  CommentViewModel(this._commentService);

  TextEditingController get controller => _controller;
  List<dynamic> get comments => _comments;
  Map<int, List<dynamic>> get replies => _replies;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  void resetPagination() {
    debugPrint('resetPagination called');
    _comments = [];
    _replies = {};
    _startIdx = 0;
    _hasMore = true;
    _errorMessage = null;
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
      _replies.clear();
      for (var comment in _comments) {
        _replies[comment['commentId']] = [];
      }
      debugPrint('Updated comments: $_comments (length: ${_comments.length})');
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

  Future<void> fetchReplies(int commentId) async {
    debugPrint('fetchReplies called for commentId: $commentId');
    // 답글 기능 미구현
  }
}