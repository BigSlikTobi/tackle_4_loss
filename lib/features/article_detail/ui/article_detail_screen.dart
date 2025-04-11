// lib/features/article_detail/ui/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:tackle_4_loss/core/widgets/global_app_bar.dart'; // Import global AppBar

class ArticleDetailScreen extends StatelessWidget {
  final int articleId; // Example: pass the ID of the article to show

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the GlobalAppBar here as well
      appBar: GlobalAppBar(
        // This screen is not the root, so automaticallyImplyLeading defaults to true
        // which will show the back button. That's usually what we want.

        // Example: Override title if needed
        // title: Text('Article Detail'),

        // Example: Add screen-specific actions
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              debugPrint('Share article $articleId');
            },
          ),
        ],
      ),
      body: Center(child: Text('Showing details for Article ID: $articleId')),
    );
  }
}
