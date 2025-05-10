import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../utils/SessionManager.dart';

class FeedCommentService {
  static const String baseUrl = 'http://localhost:8080/api/comment';

  /// 세션 정보 가져오기
  Future<Map<String, String>> getAuthHeaders() async {
    final session = await SessionManager().getSession();
    final jwt = session['jwt'];
    final userId = session['userId'];
    if (jwt == null || userId == null) {
      throw Exception('No JWT or userId found');
    }
    return {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
      'userId': userId,
    };
  }

  Future<void> postComment(String content, int feedId) async {
    final headers = await getAuthHeaders();
    final userId = headers['userId']!;

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': headers['Authorization']!,
        'userId': userId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'content': content,
        'feedId': feedId,
      }),
    );

    if (response.statusCode != 200) {
      print("댓글 등록 실패: ${response.statusCode}, 본문: ${response.body}");
      throw Exception("댓글 등록 실패: ${response.statusCode}");
    }
  }
}