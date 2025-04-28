import 'package:flutter/material.dart';

import '../models/FeedDetail.dart';
import '../models/feed.dart';
import '../services/FeedService.dart';


class FeedViewModel extends ChangeNotifier {
  final FeedRepository repository;

  List<Feed> _feeds = [];
  List<Feed> get feeds => _feeds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FeedDetail? selectedFeed;

  FeedViewModel(this.repository);

  Future<void> fetchFeeds() async {
    _isLoading = true;
    notifyListeners();

    try {
      _feeds = await repository.fetchFeeds();
    } catch (e) {
      print("Error fetching feeds: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeedDetail(int feedId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("🟡 상세 불러오기 시작");
      selectedFeed = await repository.fetchFeedDetail(feedId);
      print("🟢 상세 불러오기 성공: ${selectedFeed?.title}");
    } catch (e) {
      print("🔴 상세 불러오기 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int feedId) async {
    try {
      // 서버에서 좋아요 토글 결과 받아옴
      final resultData = await repository.toggleLike(feedId); // 0 또는 1 반환
      final liked = resultData == 1;

      // 현재 selectedFeed가 존재할 때만 처리
      if (selectedFeed != null) {
        selectedFeed = FeedDetail(
          username: selectedFeed!.username,
          title: selectedFeed!.title,
          content: selectedFeed!.content,
          hits: selectedFeed!.hits,
          createdAt: selectedFeed!.createdAt,
          sumLike: liked ? selectedFeed!.sumLike + 1 : selectedFeed!.sumLike - 1,
          liked: liked,
        );
      }

      // _feeds 리스트에서 해당 피드 찾아 업데이트
      _feeds = _feeds.map((feed) {
        if (feed.feedId == feedId) {
          return Feed(
            feedId: feed.feedId,
            title: feed.title,
            content: feed.content,
            createdAt: feed.createdAt,
            likeCount: liked ? feed.likeCount + 1 : feed.likeCount - 1,
            liked: liked,
            username: feed.username, // 추가된 필드
            hits: feed.hits, // 추가된 필드
          );
        }
        return feed;
      }).toList();

      notifyListeners();
    } catch (e) {
      print("좋아요 토글 실패: $e");
    }
  }

  Future<void> updateFeed(int feedId, String title, String content) async {
    try {
      _isLoading = true;
      notifyListeners();
      await repository.updateFeed(feedId, title, content, "456"); // 테스트용 uuid
      if (selectedFeed != null) {
        selectedFeed = FeedDetail(
          username: selectedFeed!.username,
          title: title,
          content: content,
          hits: selectedFeed!.hits,
          createdAt: selectedFeed!.createdAt,
          sumLike: selectedFeed!.sumLike,
          liked: selectedFeed!.liked,
        );
      }
      _feeds = _feeds.map((feed) {
        if (feed.feedId == feedId) {
          return Feed(
            feedId: feed.feedId,
            title: title,
            content: content,
            createdAt: feed.createdAt,
            likeCount: feed.likeCount,
            liked: feed.liked,
            username: feed.username, // 추가된 필드
            hits: feed.hits, // 추가된 필드
          );
        }
        return feed;
      }).toList();
      print("🟢 게시물 수정 성공: feedId=$feedId, title=$title");
      notifyListeners();
    } catch (e) {
      print("🔴 게시물 수정 실패: $e");
      throw Exception(
        e.toString().contains("작성자만") ? e.toString() : "게시물 수정에 실패했습니다",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}