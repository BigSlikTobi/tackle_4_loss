import 'package:flutter/foundation.dart';

@immutable
class ClusterInfo {
  final String clusterId;
  final String updatedAtString; // Keep as string from JSON: "updated_at"
  final String status;
  final String? imageUrl; // Was image_url
  final String? headline; // Default/English headline
  final String? content; // Default/English content/summary
  final String? headlineDe; // German headline
  final String? contentDe; // German content/summary

  const ClusterInfo({
    required this.clusterId,
    required this.updatedAtString,
    required this.status,
    this.imageUrl,
    this.headline,
    this.content,
    this.headlineDe,
    this.contentDe,
  });

  factory ClusterInfo.fromJson(Map<String, dynamic> json) {
    // Helper to safely get string values, returning null if empty or not string
    String? getStringOrNull(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return null;
    }

    return ClusterInfo(
      clusterId: json['clusterId'] as String? ?? '',
      updatedAtString: json['updated_at'] as String? ?? '', // Keep as string
      status: json['status'] as String? ?? 'UNKNOWN',
      imageUrl: getStringOrNull(json['image_url']),
      headline: getStringOrNull(json['headline']),
      content: getStringOrNull(json['content']), // This is HTML content
      headlineDe: getStringOrNull(json['headline_de']),
      contentDe: getStringOrNull(json['content_de']), // This is HTML content
    );
  }

  // Getter for parsed DateTime
  DateTime? get updatedAt {
    try {
      return DateTime.parse(updatedAtString);
    } catch (e) {
      debugPrint("Error parsing date: $updatedAtString - $e");
      return null;
    }
  }

  // Helper to get localized headline (Handles HTML tags like <h1>)
  String getLocalizedHeadline(String languageCode) {
    String? chosenHeadline;
    if (languageCode == 'de' && headlineDe != null && headlineDe!.isNotEmpty) {
      chosenHeadline = headlineDe;
    } else {
      chosenHeadline = headline;
    }
    chosenHeadline ??= "No Title";
    // Simple regex to remove HTML tags (can be made more robust if needed)
    return chosenHeadline.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // Helper to get localized summary/content (Handles HTML tags like <p>)
  // This content can be HTML, so the UI will need to render it appropriately if shown directly.
  String? getLocalizedContent(String languageCode) {
    String? chosenContent;
    if (languageCode == 'de' && contentDe != null && contentDe!.isNotEmpty) {
      chosenContent = contentDe;
    } else {
      chosenContent = content;
    }
    // No HTML stripping here, UI (e.g. flutter_html) should handle it if displayed.
    return chosenContent;
  }

  // primaryImageUrl uses the single imageUrl field
  String? get primaryImageUrl => imageUrl;

  int? get representativeArticleIdForNavigation {
    // Example: If clusterId could be parsed or looked up.
    // For now, returning null as we don't have this from the EF.
    debugPrint(
      "Warning: Attempting to get representativeArticleIdForNavigation for cluster $clusterId, but it's not available from 'cluster_infos' EF.",
    );
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClusterInfo &&
          runtimeType == other.runtimeType &&
          clusterId == other.clusterId;

  @override
  int get hashCode => clusterId.hashCode;
}
