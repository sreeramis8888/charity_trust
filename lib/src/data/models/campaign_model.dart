class CampaignModel {
  final String? id;
  final String? title;
  final String? description;
  final String? coverImage;
  final String? category;
  final DateTime? startDate;
  final DateTime? targetDate;
  final num? targetAmount;
  final num? collectedAmount;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CampaignModel({
    this.id,
    this.title,
    this.description,
    this.coverImage,
    this.category,
    this.startDate,
    this.targetDate,
    this.targetAmount,
    this.collectedAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// -----------------------
  /// FROM JSON
  /// -----------------------
  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      category: json['category'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'])
          : null,
      targetAmount: json['target_amount'],
      collectedAmount: json['collected_amount'] ?? 0,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// -----------------------
  /// TO JSON
  /// -----------------------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'category': category,
      'start_date': startDate?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'target_amount': targetAmount,
      'collected_amount': collectedAmount ?? 0,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// -----------------------
  /// COPY WITH
  /// -----------------------
  CampaignModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    String? category,
    DateTime? startDate,
    DateTime? targetDate,
    num? targetAmount,
    num? collectedAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      targetAmount: targetAmount ?? this.targetAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
