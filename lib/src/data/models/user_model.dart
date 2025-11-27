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
  final String? password;
  final String? status;
  final bool? isAdmin;
  final String? adminRole; // ObjectId → String
  final String? role;
  final DateTime? lastSeen;
  final bool? online;
  final DateTime? dob;
  final bool? isInstalled;
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
    this.password,
    this.status,
    this.isAdmin,
    this.adminRole,
    this.role,
    this.lastSeen,
    this.online,
    this.dob,
    this.isInstalled,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------
  // FROM JSON
  // ---------------------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      fcm: json['fcm'] as String?,
      otp: json['otp'] as String?,
      gender: json['gender'] as String?,
      bloodGroup: json['blood_group'] as String?,
      aadharNumber: json['aadhar_number'] is int
          ? json['aadhar_number']
          : int.tryParse(json['aadhar_number']?.toString() ?? ''),
      aadharCopy: json['aadhar_copy'] as String?,
      address: json['address'] as String?,
      password: json['password'] as String?,
      status: json['status'] as String?,
      isAdmin: json['is_admin'] as bool?,
      adminRole: json['admin_role'] as String?,
      role: json['role'] as String?,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'])
          : null,
      online: json['online'] as bool?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      isInstalled: json['is_installed'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // ---------------------------
  // TO JSON
  // ---------------------------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'phone': phone,
      'fcm': fcm,
      'otp': otp,
      'gender': gender,
      'blood_group': bloodGroup,
      'aadhar_number': aadharNumber,
      'aadhar_copy': aadharCopy,
      'address': address,
      'password': password,
      'status': status,
      'is_admin': isAdmin,
      'admin_role': adminRole,
      'role': role,
      'last_seen': lastSeen?.toIso8601String(),
      'online': online,
      'dob': dob?.toIso8601String(),
      'is_installed': isInstalled,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ---------------------------
  // COPYWITH
  // ---------------------------
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
    String? password,
    String? status,
    bool? isAdmin,
    String? adminRole,
    String? role,
    DateTime? lastSeen,
    bool? online,
    DateTime? dob,
    bool? isInstalled,
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
      password: password ?? this.password,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      adminRole: adminRole ?? this.adminRole,
      role: role ?? this.role,
      lastSeen: lastSeen ?? this.lastSeen,
      online: online ?? this.online,
      dob: dob ?? this.dob,
      isInstalled: isInstalled ?? this.isInstalled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
