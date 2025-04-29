import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widget/custome_appbar.dart';
import '../models/feed.dart';
import '../viewmodels/FeedViewModel.dart';
import '../../../utils/SessionManager.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    final feedVM = Provider.of<FeedViewModel>(context, listen: false);
    feedVM.fetchFeeds();
  }

  Future<void> _logout() async {
    await SessionManager().clearSession();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Scaffold(
          appBar: AppBar(
            title: customAppBar(),
          ),
          body: Column(
            children: [
              customBodyBar(context, "공지"),
              Expanded(
                child: Consumer<FeedViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: viewModel.feeds.length,
                      itemBuilder: (context, index) {
                        Feed feed = viewModel.feeds[index];
                        return PostCard(feed: feed);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}