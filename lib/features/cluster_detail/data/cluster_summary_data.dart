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
    return ClusterSummaryData(
      headline: json['headline'] as String? ?? 'No Headline',
      content:
          json['content'] as String? ??
          '<p>No Content</p>', // Default to basic HTML
      imageUrl: json['image_url'] as String?,
      headlineDe: json['headline_de'] as String?,
      contentDe: json['content_de'] as String?,
    );
  }

  String getLocalizedHeadline(String languageCode) {
    if (languageCode == 'de' && headlineDe != null && headlineDe!.isNotEmpty) {
      return headlineDe!;
    }
    return headline;
  }

  String getLocalizedContent(String languageCode) {
    if (languageCode == 'de' && contentDe != null && contentDe!.isNotEmpty) {
      return contentDe!;
    }
    return content;
  }
}
