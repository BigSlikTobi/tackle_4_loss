import 'package:flutter/foundation.dart'; // for immutable

@immutable // Good practice for model classes
class ArticlePreview {
  final int id;
  final String englishHeadline;
  final String germanHeadline;
  final String? imageUrl; // Made nullable as Image1 might be null
  final DateTime? createdAt; // Made nullable
  final String? teamId; // Made nullable
  final String status;

  const ArticlePreview({
    required this.id,
    required this.englishHeadline,
    required this.germanHeadline,
    required this.status,
    this.imageUrl,
    this.createdAt,
    this.teamId,
  });

  // Factory constructor to create an ArticlePreview from JSON
  // Matches the MappedArticle structure from your Edge Function
  factory ArticlePreview.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      try {
        // Handle potential parsing errors
        parsedDate = DateTime.tryParse(json['createdAt']);
      } catch (e) {
        debugPrint("Error parsing date: ${json['createdAt']} - $e");
        // Assign a default or handle error appropriately
      }
    }

    return ArticlePreview(
      id: json['id'] as int,
      englishHeadline: json['englishHeadline'] as String? ?? '', // Handle null
      germanHeadline: json['germanHeadline'] as String? ?? '', // Handle null
      imageUrl: json['Image'] as String?, // Key from mappedData
      createdAt: parsedDate,
      teamId: json['teamId'] as String?, // Handle null
      status: json['status'] as String? ?? '', // Handle null
    );
  }

  // Optional: Add toJson if needed, hashCode and == overrides for comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticlePreview &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
