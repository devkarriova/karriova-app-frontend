import 'package:flutter/material.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../widgets/create_post_card.dart';
import '../widgets/post_card.dart';

/// Activity feed page - displays feed of posts (LinkedIn-style)
/// Uses the post service to fetch and display posts
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          AppNavigationBar(currentRoute: AppRouter.feed),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55, // Reduced width
                ),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mockPosts.length + 1, // +1 for create post card
                    itemBuilder: (context, index) {
                    // First item is the create post card
                    if (index == 0) {
                      return CreatePostCard(
                        userInitials: 'PS',
                        onImageTap: () {
                          // TODO: Handle image upload
                        },
                        onPostTap: (content) {
                          // TODO: Handle post creation with content
                          print('Creating post: $content');
                        },
                      );
                    }

                    // Remaining items are posts
                    final post = _mockPosts[index - 1];
                    return PostCard(
                      userName: post['userName'] as String,
                      userTitle: post['userTitle'] as String,
                      timeAgo: post['timeAgo'] as String,
                      content: post['content'] as String,
                      hashtags: post['hashtags'] as List<String>,
                      likes: post['likes'] as int,
                      comments: post['comments'] as int,
                      shares: post['shares'] as int,
                      userInitials: post['userInitials'] as String,
                      onLike: () {
                        // TODO: Handle like
                      },
                      onComment: () {
                        // TODO: Handle comment
                      },
                      onShare: () {
                        // TODO: Handle share
                      },
                      onSave: () {
                        // TODO: Handle save
                      },
                    );
                  },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mock data for posts
final List<Map<String, dynamic>> _mockPosts = [
  {
    'userName': 'Rahul Verma',
    'userTitle': 'B.Tech CSE | NIT Trichy',
    'timeAgo': '2 hours ago',
    'content':
        'Just completed my first Machine Learning project! 🎉 Built a sentiment analysis model using LSTM networks. Achieved 89% accuracy on the test set. Really excited about the potential of NLP!\n\nWould love to hear feedback from the community. Also happy to share my code and learnings with anyone interested!',
    'hashtags': ['#MachineLearning', '#NLP', '#LSTM', '#Python'],
    'likes': 234,
    'comments': 45,
    'shares': 12,
    'userInitials': 'RV',
  },
  {
    'userName': 'Priya Sharma',
    'userTitle': 'B.Tech Computer Science | IIT Bombay',
    'timeAgo': '5 hours ago',
    'content':
        'Attended an amazing workshop on Cloud Computing today! Learned about AWS services, containerization with Docker, and Kubernetes orchestration. The hands-on session was incredibly insightful.',
    'hashtags': ['#CloudComputing', '#AWS', '#Docker', '#Kubernetes'],
    'likes': 156,
    'comments': 28,
    'shares': 8,
    'userInitials': 'PS',
  },
  {
    'userName': 'Arjun Patel',
    'userTitle': 'Final Year | BITS Pilani',
    'timeAgo': '1 day ago',
    'content':
        'Excited to share that I\'ve been selected for the Google Summer of Code! 🎊 Will be working on an open-source machine learning project. Grateful for this opportunity and looking forward to contributing to the community.',
    'hashtags': ['#GSoC', '#OpenSource', '#Achievement'],
    'likes': 421,
    'comments': 67,
    'shares': 34,
    'userInitials': 'AP',
  },
];
