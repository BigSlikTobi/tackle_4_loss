// lib/features/news_feed/data/story_line_item.dart
import 'package:flutter/foundation.dart';

@immutable
class StoryLineItem {
  final String headline;
  final String imageUrl;
  final String clusterId;

  const StoryLineItem({
    required this.headline,
    required this.imageUrl,
    required this.clusterId,
  });

  factory StoryLineItem.fromJson(Map<String, dynamic> json) {
    return StoryLineItem(
      headline: json['headline'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      clusterId: json['cluster_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'image_url': imageUrl,
      'cluster_id': clusterId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryLineItem &&
        other.headline == headline &&
        other.imageUrl == imageUrl &&
        other.clusterId == clusterId;
  }

  @override
  int get hashCode => Object.hash(headline, imageUrl, clusterId);

  @override
  String toString() {
    return 'StoryLineItem(headline: $headline, imageUrl: $imageUrl, clusterId: $clusterId)';
  }
}

@immutable
class StoryLinesResponse {
  final List<StoryLineItem> data;
  final StoryLinesPagination pagination;

  const StoryLinesResponse({required this.data, required this.pagination});

  factory StoryLinesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final storyLines =
        dataList
            .where((item) => item is Map<String, dynamic>)
            .map((item) => StoryLineItem.fromJson(item as Map<String, dynamic>))
            .toList();

    final paginationData = json['pagination'] as Map<String, dynamic>? ?? {};
    final pagination = StoryLinesPagination.fromJson(paginationData);

    return StoryLinesResponse(data: storyLines, pagination: pagination);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryLinesResponse &&
        listEquals(other.data, data) &&
        other.pagination == pagination;
  }

  @override
  int get hashCode => Object.hash(data, pagination);

  @override
  String toString() {
    return 'StoryLinesResponse(data: ${data.length} items, pagination: $pagination)';
  }
}

@immutable
class StoryLinesPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const StoryLinesPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory StoryLinesPagination.fromJson(Map<String, dynamic> json) {
    return StoryLinesPagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 25,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryLinesPagination &&
        other.page == page &&
        other.limit == limit &&
        other.total == total &&
        other.totalPages == totalPages &&
        other.hasNext == hasNext &&
        other.hasPrev == hasPrev;
  }

  @override
  int get hashCode {
    return Object.hash(page, limit, total, totalPages, hasNext, hasPrev);
  }

  @override
  String toString() {
    return 'StoryLinesPagination(page: $page, limit: $limit, total: $total, totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }
}
