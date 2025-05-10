import 'package:flutter/foundation.dart';

@immutable
class EnrichedArticle {
  final String id;
  final String headline;
  final String sourceName;

  const EnrichedArticle({
    required this.id,
    required this.headline,
    required this.sourceName,
  });

  factory EnrichedArticle.fromJson(Map<String, dynamic> json) {
    return EnrichedArticle(
      id: json['id'] as String? ?? '',
      headline: json['headline'] as String? ?? 'No Headline',
      sourceName: json['source_name'] as String? ?? 'Unknown Source',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrichedArticle &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
