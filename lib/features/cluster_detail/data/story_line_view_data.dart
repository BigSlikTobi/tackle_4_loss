// File: lib/features/cluster_detail/data/story_line_view_data.dart

class StoryLineViewData {
  final String headline;
  final String introduction;
  final String content;
  final String language;

  StoryLineViewData({
    required this.headline,
    required this.introduction,
    required this.content,
    required this.language,
  });

  factory StoryLineViewData.fromJson(Map<String, dynamic> json) {
    return StoryLineViewData(
      headline: json['headline'] as String? ?? '',
      introduction: json['introduction'] as String? ?? '',
      content: json['content'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'introduction': introduction,
      'content': content,
      'language': language,
    };
  }

  @override
  String toString() {
    return 'StoryLineViewData(headline: $headline, introduction: $introduction, content: ${content.length > 50 ? content.substring(0, 50) + '...' : content}, language: $language)';
  }
}

class StoryLineViewResponse {
  final StoryLineViewData data;

  StoryLineViewResponse({required this.data});

  factory StoryLineViewResponse.fromJson(Map<String, dynamic> json) {
    return StoryLineViewResponse(
      data: StoryLineViewData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.toJson()};
  }
}
