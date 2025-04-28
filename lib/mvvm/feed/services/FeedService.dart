import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/FeedDetail.dart';
import '../models/feed.dart';
import '../../../utils/SessionManager.dart';

class FeedRepository {
  final String baseUrl = "http://localhost:8080/api/feed";

  /// 세션 정보 가져오기
  Future<Map<String, String>> _getAuthHeaders() async {
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

  /// 전체 게시글 조회
  Future<List<Feed>> fetchFeeds() async {
    final headers = await _getAuthHeaders();
    final userId = headers['userId']!;
    final response = await http.get(
      Uri.parse("$baseUrl?uuid=$userId"),
      headers: {
        'Authorization': headers['Authorization']!,
      },
    );

    if (response.statusCode == 200) {
      try {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> decodedJson = jsonDecode(responseBody);

        if (decodedJson.containsKey("resultData") && decodedJson["resultData"] is List) {
          final List<dynamic> data = decodedJson["resultData"];
          return data.map((json) => Feed.fromJson(json)).toList();
        } else {
          throw Exception("서버 응답 형식이 올바르지 않습니다: 'resultData' 필드를 찾을 수 없거나 리스트 타입이 아닙니다.");
        }
      } catch (e) {
        print("JSON 처리 오류: $e");
        throw Exception("서버 응답을 처리하는 중 오류가 발생했습니다.");
      }
    } else {
      print("서버 오류: ${response.statusCode}, 본문: ${response.body}");
      throw Exception("서버 오류: ${response.statusCode}");
    }
  }

  /// 게시글 상세 조회
  Future<FeedDetail> fetchFeedDetail(int feedId) async {
    final headers = await _getAuthHeaders();
    final userId = headers['userId']!;
    final response = await http.get(
      Uri.parse("$baseUrl/detail?feedId=$feedId&uuid=$userId"),
      headers: {
        'Authorization': headers['Authorization']!,
      },
    );

    if (response.statusCode == 200) {
      try {
        final String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> decodedJson = jsonDecode(responseBody);

        if (decodedJson.containsKey("resultData")) {
          final data = decodedJson["resultData"];
          return FeedDetail.fromJson(data);
        } else {
          throw Exception("서버 응답 형식이 올바르지 않습니다: 'resultData' 필드를 찾을 수 없습니다.");
        }
      } catch (e) {
        print("JSON 처리 오류: $e");
        throw Exception("서버 응답을 처리하는 중 오류가 발생했습니다.");
      }
    } else {
      String errorBody = "(본문 없음)";
      try {
        errorBody = utf8.decode(response.bodyBytes);
      } catch (_) {}
      print("상세 조회 실패: ${response.statusCode}, 본문: $errorBody");
      throw Exception("상세 조회 실패: 서버 오류 ${response.statusCode}");
    }
  }

  /// 게시글 등록
  Future<void> postFeed(String title, String content) async {
    final headers = await _getAuthHeaders();
    final userId = headers['userId']!;
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({"title": title, "content": content, "uuid": userId}),
    );
    if (response.statusCode != 200) {
      throw Exception("게시글 등록 실패: ${response.statusCode}");
    }
  }

  /// 게시글 수정
  Future<void> updateFeed(int feedId, String title, String content, String uuid) async {
    final headers = await _getAuthHeaders();
    final userId = headers['userId']!;
    final response = await http.patch(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode({
        "feedId": feedId,
        "title": title,
        "content": content,
        "uuid": userId,
      }),
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data["resultData"] is int && data["resultData"] > 0) {
          return; // 수정 성공
        } else {
          throw Exception("게시글 수정 실패: 예상치 못한 응답");
        }
      } catch (e) {
        print("JSON 처리 오류: $e");
        throw Exception("서버 응답을 처리하는 중 오류가 발생했습니다");
      }
    } else if (response.statusCode == 403) {
      throw Exception("작성자만 게시물을 수정할 수 있습니다");
    } else {
      String errorBody = "(본문 없음)";
      try {
        errorBody = utf8.decode(response.bodyBytes);
      } catch (_) {}
      print("수정 실패: ${response.statusCode}, 본문: $errorBody");
      throw Exception("게시글 수정 실패: ${response.statusCode}");
    }
  }

  /// 게시글 삭제 (숨김 처리)
  Future<void> deleteFeed(int feedId) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse("$baseUrl/delete"),
      headers: headers,
      body: jsonEncode(feedId),
    );
    if (response.statusCode != 200) {
      throw Exception("삭제 실패: ${response.statusCode}");
    }
  }

  /// 좋아요 토글
  Future<int> toggleLike(int feedId) async {
    final headers = await _getAuthHeaders();
    final userId = headers['userId']!;
    final response = await http.get(
      Uri.parse("http://localhost:8080/api/like?feedId=$feedId&uuid=$userId"),
      headers: {
        'Authorization': headers['Authorization']!,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["resultData"] == 1 || data["resultData"] == 0) {
        return data["resultData"]; // 1이면 좋아요, 0이면 취소
      } else {
        throw Exception("좋아요 토글 실패: 예상치 못한 응답");
      }
    } else {
      throw Exception("좋아요 실패: ${response.statusCode}");
    }
  }
}