class Promotions {
  final String? id;
  final Map<String, String> title; // {"en": "...", "ml": "..."}
  final Map<String, String> description; // {"en": "...", "ml": "..."}
  final String? type;
  final String? campaign;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? media;
  final String? link;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Promotions({
    this.id,
    required this.title,
    required this.description,
    this.type,
    this.campaign,
    this.startDate,
    this.endDate,
    this.media,
    this.link,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Get title in specified language, fallback to English, then first available
  String getTitle(String languageCode) {
    return title[languageCode] ?? title['en'] ?? title.values.firstOrNull ?? '';
  }

  /// Get description in specified language, fallback to English, then first available
  String getDescription(String languageCode) {
    return description[languageCode] ?? description['en'] ?? description.values.firstOrNull ?? '';
  }

  factory Promotions.fromJson(Map<String, dynamic> json) {
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

    // Handle description - can be string or map
    Map<String, String> descriptionMap = {};
    final descriptionData = json['description'];
    if (descriptionData is Map) {
      descriptionMap = Map<String, String>.from(
        descriptionData.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    } else if (descriptionData is String) {
      descriptionMap = {'en': descriptionData};
    }

    return Promotions(
      id: json['_id']?.toString(),
      title: titleMap.isNotEmpty ? titleMap : {'en': ''},
      description: descriptionMap.isNotEmpty ? descriptionMap : {'en': ''},
      type: json['type']?.toString(),
      campaign: json['campaign']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      media: json['media']?.toString() ?? json['cover_image']?.toString(),
      link: json['link']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'type': type,
      'campaign': campaign,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'media': media,
      'link': link,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Promotions copyWith({
    String? id,
    Map<String, String>? title,
    Map<String, String>? description,
    String? type,
    String? campaign,
    DateTime? startDate,
    DateTime? endDate,
    String? media,
    String? link,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotions(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      campaign: campaign ?? this.campaign,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      media: media ?? this.media,
      link: link ?? this.link,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
