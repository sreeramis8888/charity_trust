class ParticipatedCampaignModel {
  final String? id;
  final Map<String, String> campaignName;
  final String? campaignStatus;
  final String? coverImage;
  final String? category;
  final double totalAmount;
  final int donationCount;
  final DateTime? latestDonation;

  const ParticipatedCampaignModel({
    this.id,
    required this.campaignName,
    this.campaignStatus,
    this.coverImage,
    this.category,
    this.totalAmount = 0,
    this.donationCount = 0,
    this.latestDonation,
  });

  String getTitle(String languageCode) {
    return campaignName[languageCode] ??
        campaignName['en'] ??
        campaignName.values.firstOrNull ??
        '';
  }

  static Map<String, String> _parseLocalizedMap(dynamic value) {
    if (value is Map) {
      return Map<String, String>.from(
        value.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
    if (value is String && value.isNotEmpty) {
      return {'en': value};
    }
    return {'en': ''};
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory ParticipatedCampaignModel.fromJson(Map<String, dynamic> json) {
    return ParticipatedCampaignModel(
      id: json['_id']?.toString(),
      campaignName: _parseLocalizedMap(json['campaign_name']),
      campaignStatus: json['campaign_status']?.toString(),
      coverImage: json['cover_image']?.toString(),
      category: json['category']?.toString(),
      totalAmount: _parseDouble(json['total_amount']),
      donationCount: _parseInt(json['donation_count']),
      latestDonation: json['latest_donation'] != null
          ? DateTime.tryParse(json['latest_donation'].toString())
          : null,
    );
  }
}
