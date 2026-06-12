class SubscriptionModel {
  final String? id;
  final String planId;
  final String subscriptionId;
  final String planType;
  final String period;
  final double amount;
  final String status;
  final DateTime? nextBillingDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, String> campaignTitle;
  final Map<String, String>? campaignDescription;
  final String? campaignCategory;
  final String? campaignCoverImage;
  final String? userName;
  final String? userEmail;
  final String? customerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionModel({
    this.id,
    required this.planId,
    required this.subscriptionId,
    required this.planType,
    required this.period,
    required this.amount,
    required this.status,
    this.nextBillingDate,
    this.startDate,
    this.endDate,
    required this.campaignTitle,
    this.campaignDescription,
    this.campaignCategory,
    this.campaignCoverImage,
    this.userName,
    this.userEmail,
    this.customerId,
    this.createdAt,
    this.updatedAt,
  });

  String getTitle(String languageCode) {
    return campaignTitle[languageCode] ??
        campaignTitle['en'] ??
        campaignTitle.values.firstOrNull ??
        '';
  }

  String getDescription(String languageCode) {
    final description = campaignDescription;
    if (description == null || description.isEmpty) return '';
    return description[languageCode] ??
        description['en'] ??
        description.values.firstOrNull ??
        '';
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data is Map) {
      return Map<String, String>.from(
        data.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    if (data is String) {
      return {'en': data};
    }
    return {};
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> titleMap = {};
    Map<String, String>? descriptionMap;
    String? category;
    String? coverImage;

    final campaign = json['campaign'];
    if (campaign is Map<String, dynamic>) {
      titleMap = _parseLocalizedMap(campaign['title']);
      final description = _parseLocalizedMap(campaign['description']);
      descriptionMap = description.isEmpty ? null : description;
      category = campaign['category']?.toString();
      coverImage = campaign['cover_image']?.toString();
    }

    String? userName;
    String? userEmail;
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      userName = user['name']?.toString();
      userEmail = user['email']?.toString();
    }

    return SubscriptionModel(
      id: json['_id']?.toString(),
      planId: json['plan_id']?.toString() ?? '',
      subscriptionId: json['subscription_id']?.toString() ?? '',
      planType: json['plan_type']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'created',
      nextBillingDate: json['next_billing_date'] != null
          ? DateTime.tryParse(json['next_billing_date'].toString())
          : null,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      campaignTitle: titleMap,
      campaignDescription: descriptionMap,
      campaignCategory: category,
      campaignCoverImage: coverImage,
      userName: userName,
      userEmail: userEmail,
      customerId: json['customer_id']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
