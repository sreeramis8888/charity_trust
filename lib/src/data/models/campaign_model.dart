class CampaignModel {
  final String? id;
  final String title;
  final String description;
  final String coverImage;
  final String category;
  final DateTime? startDate;
  final DateTime? targetDate;
  final double targetAmount;
  final double collectedAmount;
  final String status;
  final String approvalStatus;
  final String reason;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CampaignModel({
    this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.category,
    this.startDate,
    this.targetDate,
    required this.targetAmount,
    required this.collectedAmount,
    required this.status,
    required this.approvalStatus,
    required this.reason,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ FROM JSON
  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'] ?? '',
      category: json['category'] ?? '',
      startDate:
          json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      targetDate:
          json['target_date'] != null ? DateTime.tryParse(json['target_date']) : null,
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      collectedAmount: (json['collected_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      approvalStatus: json['approval_status'] ?? 'pending',
      reason: json['reason'] ?? '',
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deletedBy: json['deleted_by'],
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  /// ✅ TO JSON
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
      'collected_amount': collectedAmount,
      'status': status,
      'approval_status': approvalStatus,
      'reason': reason,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// ✅ COPYWITH (Optional but Recommended)
  CampaignModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    String? category,
    DateTime? startDate,
    DateTime? targetDate,
    double? targetAmount,
    double? collectedAmount,
    String? status,
    String? approvalStatus,
    String? reason,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
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
      approvalStatus: approvalStatus ?? this.approvalStatus,
      reason: reason ?? this.reason,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
