import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../utils/SessionManager.dart';

class FeedCommentService {
  static const String baseUrl = 'http://localhost:8080/api/comment';

  FeedCommentService() {
    print('FeedCommentService created');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    print('getAuthHeaders called');
    final session = await SessionManager().getSession();
    print('Session: $session');
    final jwt = session['jwt'];
    final userId = session['userId'];
    if (jwt == null || userId == null) {
      throw Exception('No JWT or userId found');
    }
    return {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
      'userId': userId,
      'Cache-Control': 'no-cache',
    };
  }

  Future<List<dynamic>> getComments(int feedId, int startIdx, int size) async {
    print('getComments called with feedId: $feedId, startIdx: $startIdx, size: $size');
    final headers = await getAuthHeaders();
    final url = '$baseUrl?feedId=$feedId&startIdx=$startIdx&size=$size';
    print('Request URL: $url');
    print('Headers: $headers');
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('댓글 조회 실패: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    print('Parsed JSON: $json');
    final commentDto = json['resultData']['commentDto'] ?? [];
    print('CommentDto: $commentDto');
    if (commentDto.isEmpty) {
      print('Warning: No comments returned from server');
    }
    return commentDto;
  }

  Future<List<dynamic>> getReplies(int parentCommentId) async {
    print('getReplies called with parentCommentId: $parentCommentId');
    final headers = await getAuthHeaders();
    final url = '$baseUrl/comment?parentCommentId=$parentCommentId';
    print('Request URL: $url');
    print('Headers: $headers');
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('대댓글 조회 실패: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    print('Parsed JSON: $json');
    final replies = json['resultData'] ?? [];
    print('Replies: $replies');
    if (replies.isEmpty) {
      print('Warning: No replies returned from server');
    }
    return replies;
  }

  Future<int> postComment(String content, int feedId) async {
    print('postComment called with content: $content, feedId: $feedId');
    final headers = await getAuthHeaders();
    final url = baseUrl;
    print('Post Comment URL: $url');
    print('Headers: $headers');
    print('Body: {"content": "$content", "feedId": $feedId}');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': headers['Authorization']!,
        'userId': headers['userId']!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'feedId': feedId,
      }),
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('댓글 등록 실패: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    final newCommentId = json['resultData'] as int;
    print('New commentId: $newCommentId');
    return newCommentId;
  }

  Future<int> postReply(String content, int feedId, int parentCommentId) async {
    print('postReply called with content: $content, feedId: $feedId, parentCommentId: $parentCommentId');
    final headers = await getAuthHeaders();
    final url = '$baseUrl/commment';
    print('Post Reply URL: $url');
    print('Headers: $headers');
    print('Body: {"content": "$content", "feedId": $feedId, "parentCommentId": $parentCommentId}');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': headers['Authorization']!,
        'userId': headers['userId']!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'feedId': feedId,
        'parentCommentId': parentCommentId,
      }),
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('대댓글 등록 실패: ${response.statusCode}');
    }
    final json = jsonDecode(response.body);
    final newReplyId = json['resultData'] as int;
    print('New replyId: $newReplyId');
    return newReplyId;
  }
}