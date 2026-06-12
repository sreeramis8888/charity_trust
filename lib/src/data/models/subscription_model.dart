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
  final DateTime? createdAt;

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
    this.createdAt,
  });

  String getTitle(String languageCode) {
    return campaignTitle[languageCode] ??
        campaignTitle['en'] ??
        campaignTitle.values.firstOrNull ??
        '';
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> titleMap = {};
    final campaign = json['campaign'];
    if (campaign is Map<String, dynamic>) {
      final titleData = campaign['title'];
      if (titleData is Map) {
        titleMap = Map<String, String>.from(
          titleData.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } else if (titleData is String) {
        titleMap = {'en': titleData};
      }
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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
