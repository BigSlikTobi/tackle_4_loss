import 'package:flutter/foundation.dart';
import 'package:tackle_4_loss/features/cluster_detail/data/enriched_article.dart';

@immutable
class ClusterTimelineEntry {
  final String dateString; // Store as string "YYYY-MM-DD"
  final String headline; // Headline of the timeline event itself
  final List<EnrichedArticle> articles;

  const ClusterTimelineEntry({
    required this.dateString,
    required this.headline,
    required this.articles,
  });

  DateTime? get date {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint("Error parsing dateString '$dateString': $e");
      return null;
    }
  }

  factory ClusterTimelineEntry.fromJson(Map<String, dynamic> json) {
    var articlesFromJson = json['articles'] as List<dynamic>? ?? [];
    List<EnrichedArticle> articleList =
        articlesFromJson
            .map((i) => EnrichedArticle.fromJson(i as Map<String, dynamic>))
            .toList();

    return ClusterTimelineEntry(
      dateString: json['date'] as String? ?? '',
      headline: json['headline'] as String? ?? 'No Event Headline',
      articles: articleList,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterTimelineEntry &&
          runtimeType == other.runtimeType &&
          dateString == other.dateString &&
          headline == other.headline;

  @override
  int get hashCode => dateString.hashCode ^ headline.hashCode;
}
