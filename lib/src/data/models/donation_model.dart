import 'campaign_model.dart';

class DonationModel {
  final String? id;
  final String? user;
  final String? user_name;
  final CampaignModel? campaign;
  final String? currency;
  final double? amount;
  final String? paymentMethod;
  final String? paymentId;
  final String? status;
  final String? receipt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DonationModel({
    this.id,
    this.user,
    this.user_name,
    this.campaign,
    this.currency,
    this.amount,
    this.paymentMethod,
    this.paymentId,
    this.status,
    this.receipt,
    this.createdAt,
    this.updatedAt,
  });

  // -----------------------------
  //         SAFE DATE PARSER
  // -----------------------------
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  //          FROM JSON
  // -----------------------------
  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json["_id"]?.toString(),
      user: json["user"]?.toString(),
      user_name: json["user_name"]?.toString(),
      campaign: json["campaign"] != null
          ? CampaignModel.fromJson(json["campaign"])
          : null,
      currency: json["currency"],
      amount: (json["amount"] is int)
          ? (json["amount"] as int).toDouble()
          : json["amount"]?.toDouble(),
      paymentMethod: json["payment_method"],
      paymentId: json["payment_id"],
      status: json["status"],
      receipt: json["receipt"],
      createdAt: _parseDate(json["createdAt"]),
      updatedAt: _parseDate(json["updatedAt"]),
    );
  }

  // -----------------------------
  //            TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user,
      "user_name": user_name,
      "campaign": campaign?.toJson(),
      "currency": currency,
      "amount": amount,
      "payment_method": paymentMethod,
      "payment_id": paymentId,
      "status": status,
      "receipt": receipt,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  // -----------------------------
  //            COPY WITH
  // -----------------------------
  DonationModel copyWith({
    String? id,
    String? user,
    String? user_name,
    CampaignModel? campaign,
    String? currency,
    double? amount,
    String? paymentMethod,
    String? paymentId,
    String? status,
    String? receipt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      user_name: user ?? this.user_name,
      campaign: campaign ?? this.campaign,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
