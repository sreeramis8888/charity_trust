import 'package:Annujoom/src/data/models/participated_campaign_model.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? image;
  final String? phone;
  final String? mobileNumber;
  final String? whatsappNo;
  final String? whatsappNumber;
  final String? fcm;
  final String? otp;
  final String? gender;
  final String? address;
  final String? area;
  final String? district;
  final String? districtCode;
  final String? state;
  final String? stateCode;
  final String? country;
  final String? countryCode;
  final String? qrCode;
  final int? pincode;
  final String? password;
  final String? status;
  final bool? isAdmin;
  final String? adminRole;
  final String? role;
  final DateTime? lastSeen;
  final bool? online;
  final DateTime? dob;
  final bool? isInstalled;
  final String? recommendedBy;
  final String? underTrustee;
  final String? underCharityMember;
  final String? rejectReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? totalCampaignsParticipated;
  final int? totalDonationsCount;
  final int? totalAmountDonated;
  final int? totalReferrals;
  final int? activeReferrals;
  final String? preferredLanguage;
  final List<ParticipatedCampaignModel> participatedCampaigns;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.image,
    this.phone,
    this.mobileNumber,
    this.whatsappNo,
    this.whatsappNumber,
    this.fcm,
    this.otp,
    this.gender,
    this.address,
    this.area,
    this.district,
    this.districtCode,
    this.state,
    this.stateCode,
    this.country,
    this.countryCode,
    this.qrCode,
    this.pincode,
    this.password,
    this.status,
    this.isAdmin,
    this.adminRole,
    this.role,
    this.lastSeen,
    this.online,
    this.dob,
    this.isInstalled,
    this.recommendedBy,
    this.underTrustee,
    this.underCharityMember,
    this.rejectReason,
    this.createdAt,
    this.updatedAt,
    this.totalCampaignsParticipated,
    this.totalDonationsCount,
    this.totalAmountDonated,
    this.totalReferrals,
    this.activeReferrals,
    this.preferredLanguage,
    this.participatedCampaigns = const [],
  });

  // -------------------------
  //          FROM JSON
  // -------------------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString(),
      name: json["name"],
      email: json["email"],
      image: json["image"],
      phone: json["phone"],

      whatsappNo: json["whatsapp_no"],
      fcm: json["fcm"],
      otp: json["otp"],
      qrCode: json["qr_code"],
      gender: json["gender"],
      address: json["address"],
      area: json["area"],
      district: json["district"],
      districtCode: json["district_code"],
      state: json["state"],
      stateCode: json["state_code"],
      country: json["country"],
      countryCode: json["country_code"],
      pincode: json["pincode"],
      password: json["password"],
      status: json["status"],
      isAdmin: json["is_admin"],
      adminRole: json["admin_role"]?.toString(),
      role: json["role"],
      lastSeen: json["last_seen"] != null
          ? DateTime.tryParse(json["last_seen"])
          : null,
      online: json["online"],
      dob: json["dob"] != null ? DateTime.tryParse(json["dob"]) : null,
      isInstalled: json["is_installed"],
      recommendedBy: json["recommended_by"],
      underTrustee: json["under_trustee"]?.toString(),
      underCharityMember: json["under_charity_member"]?.toString(),
      rejectReason: json["reject_reason"],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      totalCampaignsParticipated: json["total_campaigns_participated"] is int
          ? json["total_campaigns_participated"]
          : int.tryParse(
              json["total_campaigns_participated"]?.toString() ?? ''),
      totalDonationsCount: json["total_donations_count"] is int
          ? json["total_donations_count"]
          : int.tryParse(json["total_donations_count"]?.toString() ?? ''),
      totalAmountDonated: json["total_amount_donated"],
      totalReferrals: json["total_referrals"],
      activeReferrals: json["active_referrals"],
      preferredLanguage: json["preferred_language"],
      participatedCampaigns: (json["participated_campaigns"] as List<dynamic>?)
              ?.whereType<Map>()
              .map((item) => ParticipatedCampaignModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList() ??
          const [],
    );
  }

  // -------------------------
  //            TO JSON
  // -------------------------
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "image": image,
      "phone": phone,

      "whatsapp_no": whatsappNo,
      "fcm": fcm,
      "otp": otp,
      "qr_code": qrCode,
      "gender": gender,
      "address": address,
      "area": area,
      "district": district,
      "district_code": districtCode,
      "state": state,
      "state_code": stateCode,
      "country": country,
      "country_code": countryCode,
      "pincode": pincode,
      "password": password,
      "status": status,
      "is_admin": isAdmin,
      "admin_role": adminRole,
      "role": role,
      "last_seen": lastSeen?.toIso8601String(),
      "online": online,
      "dob": dob?.toIso8601String(),
      "is_installed": isInstalled,
      "recommended_by": recommendedBy,
      "under_trustee": underTrustee,
      "under_charity_member": underCharityMember,
      "reject_reason": rejectReason,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "total_campaigns_participated": totalCampaignsParticipated,
      "total_donations_count": totalDonationsCount,
      "total_amount_donated": totalAmountDonated,
      "total_referrals": totalReferrals,
      "active_referrals": activeReferrals,
      "preferred_language": preferredLanguage,
      "participated_campaigns": participatedCampaigns
          .map((item) => {
                "_id": item.id,
                "campaign_name": item.campaignName,
                "campaign_status": item.campaignStatus,
                "cover_image": item.coverImage,
                "category": item.category,
                "total_amount": item.totalAmount,
                "donation_count": item.donationCount,
                "latest_donation": item.latestDonation?.toIso8601String(),
              })
          .toList(),
    };
  }

  // -------------------------
  //         COPYWITH
  // -------------------------
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? qrCode,
    String? mobileNumber,
    String? whatsappNo,
    String? whatsappNumber,
    String? fcm,
    String? otp,
    String? gender,
    String? address,
    String? area,
    String? district,
    String? districtCode,
    String? state,
    String? stateCode,
    String? country,
    String? countryCode,
    int? pincode,
    String? password,
    String? status,
    bool? isAdmin,
    String? adminRole,
    String? role,
    DateTime? lastSeen,
    bool? online,
    DateTime? dob,
    bool? isInstalled,
    String? recommendedBy,
    String? underTrustee,
    String? underCharityMember,
    String? rejectReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCampaignsParticipated,
    int? totalDonationsCount,
    int? totalAmountDonated,
    int? totalReferrals,
    int? activeReferrals,
    String? preferredLanguage,
    List<ParticipatedCampaignModel>? participatedCampaigns,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      whatsappNo: whatsappNo ?? this.whatsappNo,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      fcm: fcm ?? this.fcm,
      qrCode: qrCode ?? this.qrCode,
      otp: otp ?? this.otp,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      area: area ?? this.area,
      district: district ?? this.district,
      districtCode: districtCode ?? this.districtCode,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      pincode: pincode ?? this.pincode,
      password: password ?? this.password,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      adminRole: adminRole ?? this.adminRole,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      online: online ?? this.online,
      dob: dob ?? this.dob,
      isInstalled: isInstalled ?? this.isInstalled,
      recommendedBy: recommendedBy ?? this.recommendedBy,
      underTrustee: underTrustee ?? this.underTrustee,
      underCharityMember: underCharityMember ?? this.underCharityMember,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCampaignsParticipated:
          totalCampaignsParticipated ?? this.totalCampaignsParticipated,
      totalDonationsCount: totalDonationsCount ?? this.totalDonationsCount,
      totalAmountDonated: totalAmountDonated ?? this.totalAmountDonated,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      activeReferrals: activeReferrals ?? this.activeReferrals,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      participatedCampaigns:
          participatedCampaigns ?? this.participatedCampaigns,
    );
  }
}
