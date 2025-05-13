// lib/features/cluster_detail/data/cluster_summary_data.dart
import 'package:flutter/foundation.dart';

@immutable
class ClusterSummaryData {
  final String headline;
  final String content; // This can be HTML
  final String? imageUrl;
  final String? headlineDe;
  final String? contentDe; // This can be HTML

  const ClusterSummaryData({
    required this.headline,
    required this.content,
    this.imageUrl,
    this.headlineDe,
    this.contentDe,
  });

  factory ClusterSummaryData.fromJson(Map<String, dynamic> json) {
    final rawHeadline = json['headline'] as String? ?? 'No Headline';
    final rawContent = json['content'] as String? ?? '<p>No Content</p>';
    final rawHeadlineDe = json['headline_de'] as String?;
    final rawContentDe = json['content_de'] as String?;

    debugPrint(
      "[ClusterSummaryData.fromJson] Raw Data Received:\n"
      "  headline: '$rawHeadline'\n"
      "  content (first 50): '${rawContent.substring(0, rawContent.length > 50 ? 50 : rawContent.length)}...'\n"
      "  imageUrl: '${json['image_url'] as String?}'\n"
      "  headline_de: '$rawHeadlineDe'\n"
      "  content_de (first 50): '${rawContentDe?.substring(0, rawContentDe.length > 50 ? 50 : rawContentDe.length)}...'",
    );

    return ClusterSummaryData(
      headline: rawHeadline,
      content: rawContent,
      imageUrl: json['image_url'] as String?,
      headlineDe: rawHeadlineDe,
      contentDe: rawContentDe,
    );
  }

  String getLocalizedHeadline(String languageCode) {
    debugPrint(
      "[ClusterSummaryData.getLocalizedHeadline] Called with languageCode: '$languageCode'.\n"
      "  Available headline: '$headline'\n"
      "  Available headlineDe: '$headlineDe'",
    );
    if (languageCode == 'de' && headlineDe != null && headlineDe!.isNotEmpty) {
      debugPrint(
        "[ClusterSummaryData.getLocalizedHeadline] Returning German headline: '$headlineDe'",
      );
      return headlineDe!;
    }
    debugPrint(
      "[ClusterSummaryData.getLocalizedHeadline] Returning English/default headline: '$headline'",
    );
    return headline;
  }

  String getLocalizedContent(String languageCode) {
    debugPrint(
      "[ClusterSummaryData.getLocalizedContent] Called with languageCode: '$languageCode'.\n"
      "  Available content (first 50): '${content.substring(0, content.length > 50 ? 50 : content.length)}...'\n"
      "  Available contentDe (first 50): '${contentDe?.substring(0, (contentDe?.length ?? 0) > 50 ? 50 : (contentDe?.length ?? 0))}...'",
    );
    if (languageCode == 'de' && contentDe != null && contentDe!.isNotEmpty) {
      debugPrint(
        "[ClusterSummaryData.getLocalizedContent] Returning German content (first 50): '${contentDe!.substring(0, contentDe!.length > 50 ? 50 : contentDe!.length)}...'",
      );
      return contentDe!;
    }
    debugPrint(
      "[ClusterSummaryData.getLocalizedContent] Returning English/default content (first 50): '${content.substring(0, content.length > 50 ? 50 : content.length)}...'",
    );
    return content;
  }
}
