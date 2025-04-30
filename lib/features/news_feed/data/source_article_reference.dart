import 'package:flutter/foundation.dart';

@immutable
class SourceArticleReference {
  final int id; // ID from the SourceArticles table (integer)
  final int newsSourceId; // ID referencing the Source table (integer)

  const SourceArticleReference({required this.id, required this.newsSourceId});

  factory SourceArticleReference.fromJson(Map<String, dynamic> json) {
    // Use as int? ?? 0 to handle potential null or missing keys gracefully
    return SourceArticleReference(
      id: json['id'] as int? ?? 0,
      newsSourceId: json['newsSourceId'] as int? ?? 0,
    );
  }

  // Optional: Add toJson if needed

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceArticleReference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          newsSourceId == other.newsSourceId;

  @override
  int get hashCode => Object.hash(id, newsSourceId);
}
