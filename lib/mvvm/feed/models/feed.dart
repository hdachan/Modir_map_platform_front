class Feed {
  final int feedId;
  final String title;
  final String content;
  final String createdAt;
  final int likeCount;
  final bool liked;
  final String username;
  final int hits;

  Feed({
    required this.feedId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.liked,
    required this.username,
    required this.hits,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    print("Feed.fromJson input: $json"); // 디버깅 로그 유지
    return Feed(
      feedId: _parseInt(json['feedId'], 0),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      likeCount: _parseInt(json['sumLike'], 0),
      liked: _parseInt(json['status'], 0) == 1,
      username: json['username']?.toString() ?? '',
      hits: _parseInt(json['hits'], 0),
    );
  }

  // 안전한 int 파싱 헬퍼 함수
  static int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}