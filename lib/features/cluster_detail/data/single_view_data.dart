// lib/features/cluster_detail/data/single_view_data.dart
import 'package:flutter/foundation.dart';

@immutable
class SingleViewData {
  final String headline;
  final String content; // HTML content
  final String? viewName;
  final String? specificIdentifier;
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
    final viewNameFromJson = json['view'] as String?;

    final rawHeadline = json['headline'] as String? ?? 'No Headline';
    final rawContent =
        json['content'] as String? ?? '<p>No Content Available.</p>';
    final rawHeadlineDe = json['headline_de'] as String?;
    final rawContentDe = json['content_de'] as String?;

    debugPrint(
      "[SingleViewData.fromJson] For view: '${viewNameFromJson ?? defaultViewName}', id: '$idField'. Raw Data Received:\n"
      "  headline: '$rawHeadline'\n"
      "  content (first 50): '${rawContent.substring(0, rawContent.length > 50 ? 50 : rawContent.length)}...'\n"
      "  headline_de: '$rawHeadlineDe'\n"
      "  content_de (first 50): '${rawContentDe?.substring(0, (rawContentDe.length > 50 ? 50 : rawContentDe.length))}...'",
    );

    return SingleViewData(
      headline: rawHeadline,
      content: rawContent,
      viewName: viewNameFromJson ?? defaultViewName,
      specificIdentifier: idField,
      headlineDe: rawHeadlineDe,
      contentDe: rawContentDe,
    );
  }

  String getLocalizedHeadline(String languageCode) {
    debugPrint(
      "[SingleViewData.getLocalizedHeadline] For view: '$viewName'. Called with languageCode: '$languageCode'.\n"
      "  Available headline: '$headline'\n"
      "  Available headlineDe: '$headlineDe'",
    );
    if (languageCode == 'de' && headlineDe != null && headlineDe!.isNotEmpty) {
      debugPrint(
        "[SingleViewData.getLocalizedHeadline] Returning German headline: '$headlineDe'",
      );
      return headlineDe!;
    }
    debugPrint(
      "[SingleViewData.getLocalizedHeadline] Returning English/default headline: '$headline'",
    );
    return headline;
  }

  String getLocalizedContent(String languageCode) {
    debugPrint(
      "[SingleViewData.getLocalizedContent] For view: '$viewName'. Called with languageCode: '$languageCode'.\n"
      "  Available content (first 50): '${content.substring(0, content.length > 50 ? 50 : content.length)}...'\n"
      "  Available contentDe (first 50): '${contentDe?.substring(0, (contentDe?.length ?? 0) > 50 ? 50 : (contentDe?.length ?? 0))}...'",
    );
    if (languageCode == 'de' && contentDe != null && contentDe!.isNotEmpty) {
      debugPrint(
        "[SingleViewData.getLocalizedContent] Returning German content (first 50): '${contentDe!.substring(0, contentDe!.length > 50 ? 50 : contentDe!.length)}...'",
      );
      return contentDe!;
    }
    debugPrint(
      "[SingleViewData.getLocalizedContent] Returning English/default content (first 50): '${content.substring(0, content.length > 50 ? 50 : content.length)}...'",
    );
    return content;
  }
}

@immutable
class DynamicViewsResponse {
  final List<SingleViewData> views;
  final List<String> availableViews;

  const DynamicViewsResponse({
    required this.views,
    required this.availableViews,
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

    debugPrint(
      "[DynamicViewsResponse.fromJson] Parsed ${viewsList.length} views. Available view names from JSON: $availableViewsList",
    );

    return DynamicViewsResponse(
      views: viewsList,
      availableViews: availableViewsList,
    );
  }
}
