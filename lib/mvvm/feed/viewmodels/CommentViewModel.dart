import 'package:flutter/material.dart';
import '../services/FeedCommentService.dart';

class CommentViewModel extends ChangeNotifier {
  final FeedCommentService _commentService;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _comments = [];
  Map<int, List<dynamic>> _replies = {};

  CommentViewModel(this._commentService) {
    debugPrint('CommentViewModel created with service: $_commentService');
  }

  TextEditingController get controller => _controller;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get comments => _comments;
  Map<int, List<dynamic>> get replies => _replies;

  int _startIdx = 0; // 처음 시작 인덱스
  final int _pageSize = 3; // 페이지 크기
  bool _hasMore = true; // 추가 댓글이 있는지 여부

  // 페이지네이션 초기화
  void resetPagination() {
    debugPrint('resetPagination called');
    _startIdx = 0;
    _hasMore = true;
    _comments.clear();
    _replies.clear();
    _errorMessage = null;
    notifyListeners(); // UI 갱신
  }

  Future<void> fetchComments(int feedId) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComments = await _commentService.getComments(feedId, _startIdx, _pageSize);

      if (newComments.length < _pageSize) {
        _hasMore = false; // 더 이상 댓글 없음
      }

      _comments.addAll(newComments);
      _startIdx += newComments.length;

      _replies.clear();
      for (var comment in _comments) {
        _replies[comment['commentId']] = [];
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = "댓글 로드 실패: $e";
      debugPrint('fetchComments Error: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get hasMore => _hasMore;

  Future<void> fetchReplies(int parentCommentId) async {
    debugPrint('fetchReplies called with parentCommentId: $parentCommentId');
    try {
      final replies = await _commentService.getReplies(parentCommentId);
      debugPrint('Replies loaded: ${replies.length}, Data: $replies');
      _replies[parentCommentId] = replies;
      notifyListeners();
    } catch (e) {
      _errorMessage = "대댓글 로드 실패: $e";
      debugPrint('fetchReplies Error: $e');
      notifyListeners();
    }
  }

  Future<void> postComment(int feedId) async {
    if (_controller.text.isEmpty) return;
    debugPrint('postComment called with feedId: $feedId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _commentService.postComment(_controller.text, feedId);
      _controller.clear();
      resetPagination(); // 새 댓글 추가 후 초기화
      await fetchComments(feedId); // fetchComments에서 notifyListeners 호출
    } catch (e) {
      _errorMessage = "댓글 등록에 실패했습니다. 다시 시도해주세요.";
      debugPrint('postComment Error: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    debugPrint('clearData called');
    _comments.clear();
    _replies.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CommentViewModel disposed');
    _controller.dispose();
    super.dispose();
  }
}