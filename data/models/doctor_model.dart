// Doctor Model
// نموذج بيانات الطبيب
class DoctorModel {
  final String id;
  final String name;
  final String specialty; // التخصص
  final String email;
  final String? phone;
  final String? photoUrl;
  final String status; // 'active', 'inactive', 'suspended'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    this.phone,
    this.photoUrl,
    this.status = 'active',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
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
      'specialty': specialty,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  DoctorModel copyWith({
    String? name,
    String? specialty,
    String? email,
    String? phone,
    String? photoUrl,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      id: id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
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
