class CampaignModel {
  final String? id;
  final String? title;
  final String? description;
  final String? coverImage;
  final String? category;
  final DateTime? startDate;
  final DateTime? targetDate;
  final int? targetAmount;
  final int? collectedAmount;
  final String? status;
  final String? approvalStatus;
  final String? reason;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;
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
    this.approvalStatus,
    this.reason,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
  });

  // -----------------------------
  //         FROM JSON
  // -----------------------------
  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return CampaignModel(
      id: json["_id"]?.toString(),
      title: json["title"],
      description: json["description"],
      coverImage: json["cover_image"],
      category: json["category"],
      startDate: parseDate(json["start_date"]),
      targetDate: parseDate(json["target_date"]),
      targetAmount: json["target_amount"],
      collectedAmount: json["collected_amount"],
      status: json["status"],
      approvalStatus: json["approval_status"],
      reason: json["reason"],
      createdBy: json["created_by"]?.toString(),
      updatedBy: json["updated_by"]?.toString(),
      deletedBy: json["deleted_by"]?.toString(),
      createdAt: parseDate(json["createdAt"]),
      updatedAt: parseDate(json["updatedAt"]),
    );
  }

  // -----------------------------
  //           TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "description": description,
      "cover_image": coverImage,
      "category": category,
      "start_date": startDate?.toIso8601String(),
      "target_date": targetDate?.toIso8601String(),
      "target_amount": targetAmount,
      "collected_amount": collectedAmount,
      "status": status,
      "approval_status": approvalStatus,
      "reason": reason,
      "created_by": createdBy,
      "updated_by": updatedBy,
      "deleted_by": deletedBy,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  // -----------------------------
  //           COPY WITH
  // -----------------------------
  CampaignModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    String? category,
    DateTime? startDate,
    DateTime? targetDate,
    int? targetAmount,
    int? collectedAmount,
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
