// Patient Model
// نموذج بيانات المريض
class PatientModel {
  final String id;
  final String name;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? phone;
  final String? email;
  final String? photoUrl;
  final String diagnosis; // التشخيص
  final String? stage; // المرحلة
  final String? doctorId;
  final String? nurseId;
  final String? allergies; // الحساسية
  final String status; // 'active', 'discharged', 'transferred'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PatientModel({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.email,
    this.photoUrl,
    required this.diagnosis,
    this.stage,
    this.doctorId,
    this.nurseId,
    this.allergies,
    this.status = 'active',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate age from dateOfBirth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // From Firestore
  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      name: map['name'] ?? '',
      dateOfBirth: map['dateOfBirth']?.toDate(),
      gender: map['gender'],
      phone: map['phone'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      diagnosis: map['diagnosis'] ?? '',
      stage: map['stage'],
      doctorId: map['doctorId'],
      nurseId: map['nurseId'],
      allergies: map['allergies'],
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
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'diagnosis': diagnosis,
      'stage': stage,
      'doctorId': doctorId,
      'nurseId': nurseId,
      'allergies': allergies,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  PatientModel copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    String? email,
    String? photoUrl,
    String? diagnosis,
    String? stage,
    String? doctorId,
    String? nurseId,
    String? allergies,
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      diagnosis: diagnosis ?? this.diagnosis,
      stage: stage ?? this.stage,
      doctorId: doctorId ?? this.doctorId,
      nurseId: nurseId ?? this.nurseId,
      allergies: allergies ?? this.allergies,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
