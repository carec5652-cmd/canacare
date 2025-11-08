import 'package:admin_can_care/data/models/notification_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';

// Notification Repository
// مستودع الإشعارات
class NotificationRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'notifications';

  // Stream Notifications
  // تدفق الإشعارات
  Stream<List<NotificationModel>> streamNotifications() {
    return _firestoreService
        .streamCollection(
          _collection,
          queryBuilder: (query) => query.orderBy('createdAt', descending: true),
        )
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
                  )
                  .toList(),
        );
  }

  // Create Notification
  // إنشاء إشعار
  Future<String> createNotification(NotificationModel notification) async {
    try {
      return await _firestoreService.createDocument(_collection, notification.toMap());
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  // Update Notification Status
  // تحديث حالة الإشعار
  Future<void> updateNotificationStatus(String id, String status) async {
    try {
      await _firestoreService.updateDocument(_collection, id, {'status': status});
    } catch (e) {
      throw 'Failed to update notification status: $e';
    }
  }

  // Delete Notification
  // حذف إشعار
  Future<void> deleteNotification(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id);
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }
}
