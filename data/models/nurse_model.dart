// Nurse Model
// نموذج بيانات الممرض
class NurseModel {
  final String id;
  final String name;
  final String department; // القسم
  final String email;
  final String? phone;
  final String? photoUrl;
  final String status; // 'active', 'inactive', 'suspended'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NurseModel({
    required this.id,
    required this.name,
    required this.department,
    required this.email,
    this.phone,
    this.photoUrl,
    this.status = 'active',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory NurseModel.fromMap(Map<String, dynamic> map, String id) {
    return NurseModel(
      id: id,
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      status: map['status'] ?? 'active',
      notes: map['notes'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  NurseModel copyWith({
    String? name,
    String? department,
    String? email,
    String? phone,
    String? photoUrl,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return NurseModel(
      id: id,
      name: name ?? this.name,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
