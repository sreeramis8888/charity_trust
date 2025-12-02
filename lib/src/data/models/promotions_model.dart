class Promotions {
  final String? id;
  final String? title;
  final String? description;
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
    this.title,
    this.description,
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

  factory Promotions.fromJson(Map<String, dynamic> json) {
    return Promotions(
      id: json['_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      type: json['type']?.toString(),
      campaign: json['campaign']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      media: json['media']?.toString(),
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
    String? title,
    String? description,
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
