import 'package:flutter/material.dart';
import '../services/FeedCommentService.dart';

class CommentViewModel extends ChangeNotifier {
  final FeedCommentService _commentService;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  CommentViewModel(this._commentService);

  TextEditingController get controller => _controller;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> postComment(int feedId) async {
    if (_controller.text.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentService.postComment(_controller.text, feedId);
      _controller.clear();
    } catch (e) {
      print("댓글 등록 오류: $e");
      _errorMessage = "댓글 등록에 실패했습니다. 다시 시도해주세요.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}