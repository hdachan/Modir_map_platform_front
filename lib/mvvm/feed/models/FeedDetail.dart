class FeedDetail {
  final String username;
  final String title;
  final String content;
  final int hits;
  final String createdAt;
  final int sumLike;
  final bool liked;
  final bool isAuthor; // int -> bool

  FeedDetail({
    required this.username,
    required this.title,
    required this.content,
    required this.hits,
    required this.createdAt,
    required this.sumLike,
    required this.liked,
    required this.isAuthor,
  });

  factory FeedDetail.fromJson(Map<String, dynamic> json) {
    print("FeedDetail.fromJson input: $json");
    return FeedDetail(
      username: json['username']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      hits: _parseInt(json['hits'], 0),
      createdAt: json['createdAt']?.toString() ?? '',
      sumLike: _parseInt(json['sumLike'], 0),
      liked: _parseInt(json['status'], 0) == 1,
      isAuthor: json['isAuthor'] == true || _parseInt(json['isAuthor'], 0) == 1, // bool 또는 int 처리
    );
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}