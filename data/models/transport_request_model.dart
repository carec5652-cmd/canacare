// Transport Request Model
// نموذج بيانات طلبات النقل
class TransportRequestModel {
  final String id;
  final String patientId;
  final String? patientName;
  final String fromLocation; // نقطة الانطلاق
  final String toLocation; // الوجهة
  final DateTime requestedAt;
  final String status; // 'pending', 'assigned', 'in_progress', 'completed', 'cancelled'
  final String? assignedDriverId;
  final String? assignedDriverName;
  final String? notes;
  final DateTime? completedAt;
  final DateTime createdAt;

  TransportRequestModel({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.fromLocation,
    required this.toLocation,
    required this.requestedAt,
    this.status = 'pending',
    this.assignedDriverId,
    this.assignedDriverName,
    this.notes,
    this.completedAt,
    required this.createdAt,
  });

  // From Firestore
  factory TransportRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return TransportRequestModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
      requestedAt: map['requestedAt']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      assignedDriverId: map['assignedDriverId'],
      assignedDriverName: map['assignedDriverName'],
      notes: map['notes'],
      completedAt: map['completedAt']?.toDate(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'requestedAt': requestedAt,
      'status': status,
      'assignedDriverId': assignedDriverId,
      'assignedDriverName': assignedDriverName,
      'notes': notes,
      'completedAt': completedAt,
      'createdAt': createdAt,
    };
  }

  TransportRequestModel copyWith({
    String? patientName,
    String? status,
    String? assignedDriverId,
    String? assignedDriverName,
    String? notes,
    DateTime? completedAt,
  }) {
    return TransportRequestModel(
      id: id,
      patientId: patientId,
      patientName: patientName ?? this.patientName,
      fromLocation: fromLocation,
      toLocation: toLocation,
      requestedAt: requestedAt,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

