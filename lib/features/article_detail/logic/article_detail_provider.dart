// lib/features/article_detail/logic/article_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tackle_4_loss/features/article_detail/data/article_detail.dart';
import 'package:tackle_4_loss/features/article_detail/data/article_detail_service.dart';

// Provider for the service instance
final articleDetailServiceProvider = Provider<ArticleDetailService>((ref) {
  return ArticleDetailService();
});

// FutureProvider.family to fetch details for a specific article ID
final articleDetailProvider = FutureProvider.family<ArticleDetail, int>((
  ref,
  articleId,
) async {
  // Get the service
  final service = ref.watch(articleDetailServiceProvider);
  // Fetch the data
  return service.getArticleDetail(articleId);
});
