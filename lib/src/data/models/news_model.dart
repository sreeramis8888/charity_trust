class NewsModel {
  final String? id;
  final String? category;
  final String? title;
  final String? subTitle;
  final String? content;
  final String? media;
  final String? status;
  final String? link;
  final List<String>? bookmarked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsModel({
    this.id,
    this.category,
    this.title,
    this.subTitle,
    this.content,
    this.media,
    this.status,
    this.link,
    this.bookmarked,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json["_id"]?.toString(),
      category: json["category"]?.toString(),
      title: json["title"]?.toString(),
      subTitle: json["sub_title"]?.toString(),
      content: json["content"]?.toString(),
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
      "sub_title": subTitle,
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
    String? title,
    String? subTitle,
    String? content,
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
      subTitle: subTitle ?? this.subTitle,
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
