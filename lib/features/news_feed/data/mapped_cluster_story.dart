import 'package:flutter/foundation.dart';
import 'package:tackle_4_loss/features/news_feed/data/source_article_reference.dart'; // Import the new model

@immutable
class MappedClusterStory {
  final String id; // UUID from the ClusterStories table (string)
  final String clusterId; // UUID of the cluster (string)
  final String englishHeadline;
  final String germanHeadline;
  final String? summaryEnglish; // Nullable
  final String? summaryGerman; // Nullable
  final String? image1Url; // Nullable
  final String? image2Url; // Nullable
  final String? image3Url; // Nullable
  final DateTime? updatedAt; // Nullable if parsing fails
  final List<SourceArticleReference> sourceArticles; // List of references

  // --- Enhancement: Add representative source article ID ---
  // The backend schema doesn't explicitly provide this, but we need a way
  // to know which SourceArticle ID to use when tapping the main cluster view
  // to go to detail. For now, we'll just use the ID of the *first* item
  // in the sourceArticles list as the representative. A better approach
  // would be for the backend to select and provide this ID.
  int? get representativeSourceArticleId {
    return sourceArticles.isNotEmpty ? sourceArticles.first.id : null;
  }
  // --- End Enhancement ---

  const MappedClusterStory({
    required this.id,
    required this.clusterId,
    required this.englishHeadline,
    required this.germanHeadline,
    this.summaryEnglish,
    this.summaryGerman,
    this.image1Url,
    this.image2Url,
    this.image3Url,
    this.updatedAt,
    this.sourceArticles = const [], // Default to empty list
  });

  factory MappedClusterStory.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['updated_at'] != null && json['updated_at'] is String) {
      try {
        // Assuming ISO 8601 format from backend (like '2025-04-23T13:10:40.529403+00:00')
        parsedDate = DateTime.parse(json['updated_at']);
      } catch (e) {
        debugPrint("Error parsing date: ${json['updated_at']} - $e");
      }
    }

    // Helper to safely get string values, returning null if empty or not string
    String? getStringOrNull(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return null;
    }

    // Parse the list of source articles
    final List<dynamic>? sourceArticlesJson =
        json['sourceArticles'] as List<dynamic>?;
    final List<SourceArticleReference> parsedSourceArticles =
        sourceArticlesJson
            ?.map((item) {
              if (item is Map<String, dynamic>) {
                return SourceArticleReference.fromJson(item);
              }
              debugPrint("Skipping invalid source article reference: $item");
              return null; // Skip invalid items
            })
            .whereType<SourceArticleReference>() // Filter out nulls
            .toList() ??
        []; // Default to empty list

    return MappedClusterStory(
      id: json['id'] as String? ?? '', // UUID is string
      clusterId: json['cluster_id'] as String? ?? '', // UUID is string
      englishHeadline: json['headline_english'] as String? ?? '',
      germanHeadline: json['headline_german'] as String? ?? '',
      summaryEnglish: getStringOrNull(json['summary_english']),
      summaryGerman: getStringOrNull(json['summary_german']),
      image1Url: getStringOrNull(json['image1_url']),
      image2Url: getStringOrNull(json['image2_url']),
      image3Url: getStringOrNull(json['image3_url']),
      updatedAt: parsedDate,
      sourceArticles: parsedSourceArticles,
    );
  }

  // Optional: Helper to get localized headline (Handles HTML tags like <h1>)
  String getLocalizedHeadline(String languageCode) {
    String headline = englishHeadline;
    if (languageCode == 'de' && germanHeadline.isNotEmpty) {
      headline = germanHeadline;
    }
    // Simple regex to remove HTML tags (can be made more robust if needed)
    return headline.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // Optional: Helper to get localized summary (Handles HTML tags like <p>)
  String? getLocalizedSummary(String languageCode) {
    String? summary = summaryEnglish;
    if (languageCode == 'de' && summaryGerman != null) {
      summary = summaryGerman;
    }
    if (summary == null) return null;
    // Simple regex to remove HTML tags
    return summary.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // Helper to get the primary image URL with fallback
  String? get primaryImageUrl {
    if (image1Url != null && image1Url!.isNotEmpty) return image1Url;
    if (image2Url != null && image2Url!.isNotEmpty) return image2Url;
    if (image3Url != null && image3Url!.isNotEmpty) return image3Url;
    return null; // No valid image found
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MappedClusterStory &&
          runtimeType == other.runtimeType &&
          id == other.id; // Use UUID for equality check

  @override
  int get hashCode => id.hashCode;
}
