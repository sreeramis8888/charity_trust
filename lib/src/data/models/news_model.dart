class NewsModel {
  final String? id;
  final String? category;
  final Map<String, String> title; // {"en": "...", "ml": "..."}
  final Map<String, String> subtitle; // {"en": "...", "ml": "..."}
  final Map<String, String> content; // {"en": "...", "ml": "..."}
  final String? media;
  final String? status;
  final String? link;
  final List<String>? bookmarked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsModel({
    this.id,
    this.category,
    required this.title,
    required this.subtitle,
    required this.content,
    this.media,
    this.status,
    this.link,
    this.bookmarked,
    this.createdAt,
    this.updatedAt,
  });

  /// Get title in specified language, fallback to English, then first available
  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? title.values.firstOrNull ?? '';
  }

  /// Get subtitle in specified language, fallback to English, then first available
  String getSubtitle(String languageCode) {
    return subtitle[languageCode] ?? subtitle['en'] ?? subtitle.values.firstOrNull ?? '';
  }

  /// Get content in specified language, fallback to English, then first available
  String getContent(String languageCode) {
    return content[languageCode] ?? content['en'] ?? content.values.firstOrNull ?? '';
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Handle title - can be string or map
    Map<String, String> titleMap = {};
    final titleData = json['title'];
    if (titleData is Map) {
      titleMap = Map<String, String>.from(
        titleData.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    } else if (titleData is String) {
      titleMap = {'en': titleData};
    }

    // Handle subtitle - can be string or map
    Map<String, String> subtitleMap = {};
    final subtitleData = json['sub_title'];
    if (subtitleData is Map) {
      subtitleMap = Map<String, String>.from(
        subtitleData.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    } else if (subtitleData is String) {
      subtitleMap = {'en': subtitleData};
    }

    // Handle content - can be string or map
    Map<String, String> contentMap = {};
    final contentData = json['content'];
    if (contentData is Map) {
      contentMap = Map<String, String>.from(
        contentData.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    } else if (contentData is String) {
      contentMap = {'en': contentData};
    }

    return NewsModel(
      id: json["_id"]?.toString(),
      category: json["category"]?.toString(),
      title: titleMap.isNotEmpty ? titleMap : {'en': ''},
      subtitle: subtitleMap.isNotEmpty ? subtitleMap : {'en': ''},
      content: contentMap.isNotEmpty ? contentMap : {'en': ''},
      media: json["media"]?.toString(),
      status: json["status"]?.toString(),
      link: json["link"]?.toString(),
      bookmarked: (json["bookmarked"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "category": category,
      "title": title,
      "sub_title": subtitle,
      "content": content,
      "media": media,
      "status": status,
      "link": link,
      "bookmarked": bookmarked,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  NewsModel copyWith({
    String? id,
    String? category,
    Map<String, String>? title,
    Map<String, String>? subtitle,
    Map<String, String>? content,
    String? media,
    String? status,
    String? link,
    List<String>? bookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      media: media ?? this.media,
      status: status ?? this.status,
      link: link ?? this.link,
      bookmarked: bookmarked ?? this.bookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
