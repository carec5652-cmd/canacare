// Admin Model
// نموذج بيانات المشرف
class AdminModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? photoUrl;
  final String role; // 'admin' or 'superadmin'
  final String? preferredLocale; // 'en' or 'ar'
  final String? preferredTheme; // 'light' or 'dark'
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.photoUrl,
    this.role = 'admin',
    this.preferredLocale,
    this.preferredTheme,
    required this.createdAt,
    this.lastLogin,
  });

  // From Firestore
  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'admin',
      preferredLocale: map['preferredLocale'],
      preferredTheme: map['preferredTheme'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: map['lastLogin']?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'preferredLocale': preferredLocale,
      'preferredTheme': preferredTheme,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  AdminModel copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    String? preferredLocale,
    String? preferredTheme,
    DateTime? lastLogin,
  }) {
    return AdminModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
