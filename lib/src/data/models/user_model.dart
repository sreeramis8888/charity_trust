class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? image;
  final String? phone;
  final String? fcm;
  final String? otp;
  final String? gender;
  final String? bloodGroup;
  final int? aadharNumber;
  final String? aadharCopy;
  final String? address;
  final String? area;
  final String? district;
  final String? state;
  final String? country;
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

  UserModel({
    this.id,
    this.name,
    this.email,
    this.image,
    this.phone,
    this.fcm,
    this.otp,
    this.gender,
    this.bloodGroup,
    this.aadharNumber,
    this.aadharCopy,
    this.address,
    this.area,
    this.district,
    this.state,
    this.country,
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
  });

  // -----------------------------
  // FROM JSON
  // -----------------------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"],
      name: json["name"],
      email: json["email"],
      image: json["image"],
      phone: json["phone"],
      fcm: json["fcm"],
      otp: json["otp"],
      gender: json["gender"],
      bloodGroup: json["blood_group"],
      aadharNumber: json["aadhar_number"],
      aadharCopy: json["aadhar_copy"],
      address: json["address"],
      area: json["area"],
      district: json["district"],
      state: json["state"],
      country: json["country"],
      pincode: json["pincode"],
      password: json["password"],
      status: json["status"],
      isAdmin: json["is_admin"],
      adminRole: json["admin_role"],
      role: json["role"],
      lastSeen: json["last_seen"] != null
          ? DateTime.tryParse(json["last_seen"])
          : null,
      online: json["online"],
      dob: json["dob"] != null ? DateTime.tryParse(json["dob"]) : null,
      isInstalled: json["is_installed"],
      recommendedBy: json["recommended_by"],
      underTrustee: json["under_trustee"],
      underCharityMember: json["under_charity_member"],
      rejectReason: json["reject_reason"],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
    );
  }

  // -----------------------------
  // TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "image": image,
      "phone": phone,
      "fcm": fcm,
      "otp": otp,
      "gender": gender,
      "blood_group": bloodGroup,
      "aadhar_number": aadharNumber,
      "aadhar_copy": aadharCopy,
      "address": address,
      "area": area,
      "district": district,
      "state": state,
      "country": country,
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
    };
  }

  // -----------------------------
  // COPY WITH
  // -----------------------------
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? fcm,
    String? otp,
    String? gender,
    String? bloodGroup,
    int? aadharNumber,
    String? aadharCopy,
    String? address,
    String? area,
    String? district,
    String? state,
    String? country,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      fcm: fcm ?? this.fcm,
      otp: otp ?? this.otp,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      aadharCopy: aadharCopy ?? this.aadharCopy,
      address: address ?? this.address,
      area: area ?? this.area,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
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
    );
  }
}
