// File: lib/features/cluster_detail/data/single_view_data.dart
import 'package:flutter/foundation.dart';

@immutable
class SingleViewData {
  final String headline;
  final String content; // HTML content
  final String?
  viewName; // e.g., "Coach", "Player", "GM", "Roster" - useful for dynamic views
  final String? specificIdentifier; // e.g., coach's name, player's name
  final String? headlineDe;
  final String? contentDe;

  const SingleViewData({
    required this.headline,
    required this.content,
    this.viewName,
    this.specificIdentifier,
    this.headlineDe,
    this.contentDe,
  });

  factory SingleViewData.fromJson(
    Map<String, dynamic> json, {
    String? defaultViewName,
  }) {
    // Try to get a specific identifier (coach name, player name, etc.)
    String? idField;
    if (json.containsKey('coach')) {
      idField = json['coach'] as String?;
    } else if (json.containsKey('player')) {
      idField = json['player'] as String?;
    } else if (json.containsKey('franchise')) {
      idField = json['franchise'] as String?;
    } else if (json.containsKey('team')) {
      idField = json['team'] as String?;
    }
    // 'view' field for dynamic views
    final viewNameFromJson = json['view'] as String?;

    return SingleViewData(
      headline: json['headline'] as String? ?? 'No Headline',
      content: json['content'] as String? ?? '<p>No Content Available.</p>',
      viewName: viewNameFromJson ?? defaultViewName,
      specificIdentifier: idField,
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

// --- For Dynamic Views Response ---
@immutable
class DynamicViewsResponse {
  final List<SingleViewData> views;
  final List<String> availableViews; // e.g., ["GM", "Roster"]
  // final String? language; // language from response, if needed globally

  const DynamicViewsResponse({
    required this.views,
    required this.availableViews,
    // this.language,
  });

  factory DynamicViewsResponse.fromJson(Map<String, dynamic> json) {
    final viewsList =
        (json['views'] as List<dynamic>?)
            ?.map((v) => SingleViewData.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    final availableViewsList =
        (json['available_views'] as List<dynamic>?)
            ?.map((av) => av as String)
            .toList() ??
        [];

    return DynamicViewsResponse(
      views: viewsList,
      availableViews: availableViewsList,
      // language: json['language'] as String?,
    );
  }
}
