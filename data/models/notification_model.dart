// Notification Model
// نموذج بيانات الإشعارات
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String targetAudience; // 'all', 'doctors', 'nurses', 'patients', 'custom'
  final List<String>? targetUserIds; // For custom targeting
  final String? imageUrl;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final String createdBy; // Admin ID
  final String status; // 'pending', 'sent', 'failed'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetAudience,
    this.targetUserIds,
    this.imageUrl,
    this.scheduledAt,
    required this.createdAt,
    required this.createdBy,
    this.status = 'pending',
  });

  // From Firestore
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      targetAudience: map['targetAudience'] ?? 'all',
      targetUserIds: map['targetUserIds'] != null ? List<String>.from(map['targetUserIds']) : null,
      imageUrl: map['imageUrl'],
      scheduledAt: map['scheduledAt']?.toDate(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'targetAudience': targetAudience,
      'targetUserIds': targetUserIds,
      'imageUrl': imageUrl,
      'scheduledAt': scheduledAt,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'status': status,
    };
  }
}
