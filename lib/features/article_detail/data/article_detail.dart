// lib/features/article_detail/data/article_detail.dart
import 'package:flutter/foundation.dart';

@immutable
class ArticleDetail {
  final int id;
  final String englishHeadline;
  final String germanHeadline;
  final String? contentEnglish; // Nullable if can be empty
  final String? contentGerman; // Nullable if can be empty
  final String? image1;
  final String? image2;
  final String? image3;
  final DateTime? createdAt; // Use DateTime for easier handling
  final String? sourceUrl;
  final String? sourceName;
  final String? teamId;
  final String? status;
  // final String? updatedBy; // Add if needed

  const ArticleDetail({
    required this.id,
    required this.englishHeadline,
    required this.germanHeadline,
    this.contentEnglish,
    this.contentGerman,
    this.image1,
    this.image2,
    this.image3,
    this.createdAt,
    this.sourceUrl,
    this.sourceName,
    this.teamId,
    this.status,
    // this.updatedBy,
  });

  factory ArticleDetail.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null && json['createdAt'] is String) {
      try {
        parsedDate = DateTime.tryParse(json['createdAt']);
      } catch (e) {
        debugPrint("Error parsing date: ${json['createdAt']} - $e");
      }
    }

    // Helper to safely get string values, returning null if empty or not string
    String? getStringOrNull(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
      return null;
    }

    return ArticleDetail(
      id: json['id'] as int? ?? 0, // Provide default or handle error
      englishHeadline: json['englishHeadline'] as String? ?? '',
      germanHeadline: json['germanHeadline'] as String? ?? '',
      contentEnglish: getStringOrNull(json['ContentEnglish']),
      contentGerman: getStringOrNull(json['ContentGerman']),
      image1: getStringOrNull(json['Image1']),
      image2: getStringOrNull(json['Image2']),
      image3: getStringOrNull(json['Image3']),
      createdAt: parsedDate,
      sourceUrl: getStringOrNull(json['sourceUrl']),
      sourceName: getStringOrNull(json['SourceName']),
      teamId: getStringOrNull(json['teamId']),
      status: getStringOrNull(json['status']),
      // updatedBy: getStringOrNull(json['UpdatedBy']),
    );
  }

  // Optional: Helper to get localized headline
  String getLocalizedHeadline(String languageCode) {
    if (languageCode == 'de' && germanHeadline.isNotEmpty) {
      return germanHeadline;
    }
    return englishHeadline.isNotEmpty ? englishHeadline : "No Title";
  }

  // Optional: Helper to get localized content
  String? getLocalizedContent(String languageCode) {
    if (languageCode == 'de' && contentGerman != null) {
      return contentGerman;
    }
    // Fallback to English if German is null or language is not German
    return contentEnglish;
  }

  // --- NEW: Helper to get the primary image URL with fallback ---
  String? get primaryImageUrl {
    if (image1 != null && image1!.isNotEmpty) {
      return image1;
    }
    if (image2 != null && image2!.isNotEmpty) {
      return image2;
    }
    if (image3 != null && image3!.isNotEmpty) {
      return image3;
    }
    return null; // No valid image found
  }
  // --- End New Helper ---

  // Keep this if needed elsewhere, but primaryImageUrl is preferred for the detail view
  List<String> get validImageUrls {
    return [image1, image2, image3].whereType<String>().toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
