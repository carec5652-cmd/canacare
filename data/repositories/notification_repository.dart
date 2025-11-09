// استيراد نموذج بيانات الإشعار - لتعريف بنية بيانات الإشعار
import 'package:admin_can_care/data/models/notification_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';
// استيراد خدمة FCM - لإرسال الإشعارات الفورية عبر Firebase Cloud Messaging
import 'package:admin_can_care/data/services/fcm_service.dart';
// استيراد خدمة Cloud Functions - لإرسال الإشعارات من الويب
import 'package:admin_can_care/data/services/cloud_functions_service.dart';
// استيراد kIsWeb - للتحقق مما إذا كان التطبيق يعمل على منصة الويب
import 'package:flutter/foundation.dart' show kIsWeb;

// Notification Repository - مستودع الإشعارات
// يدير جميع عمليات الإشعارات (الإنشاء، القراءة، التحديث، الحذف)
// ويتعامل مع إرسال الإشعارات الفورية للمستخدمين
class NotificationRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final FCMService _fcmService = FCMService(); // مثيل خدمة FCM
  final CloudFunctionsService _cloudFunctions = CloudFunctionsService(); // مثيل خدمة Cloud Functions
  final String _collection = 'notifications'; // اسم مجموعة الإشعارات في Firestore

  // Stream Notifications - تدفق الإشعارات
  // دالة تُرجع تدفقاً (Stream) من قائمة الإشعارات في الوقت الفعلي
  // تستمع للتغييرات في Firestore وتحدّث الواجهة تلقائياً
  Stream<List<NotificationModel>> streamNotifications() {
    return _firestoreService // استدعاء خدمة Firestore
        .streamCollection( // الحصول على تدفق مجموعة البيانات
          _collection, // اسم المجموعة: 'notifications'
          queryBuilder: (query) => query.orderBy('createdAt', descending: true), // ترتيب تنازلي حسب تاريخ الإنشاء (الأحدث أولاً)
        )
        .map( // تحويل البيانات من QuerySnapshot إلى قائمة NotificationModel
          (snapshot) => // لكل snapshot (لقطة بيانات)
              snapshot.docs // الحصول على جميع المستندات
                  .map( // تحويل كل مستند
                    (doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id), // من Map إلى NotificationModel
                  )
                  .toList(), // تحويل النتيجة إلى قائمة
        );
  }

  // Create Notification and Send Push - إنشاء إشعار وإرساله
  // دالة لإنشاء إشعار جديد في Firestore وإرساله كإشعار فوري (Push Notification)
  Future<String> createNotification(NotificationModel notification) async {
    try {
      // Save to Firestore - حفظ الإشعار في قاعدة البيانات
      String docId = await _firestoreService.createDocument(_collection, notification.toMap()); // إنشاء مستند جديد وإرجاع معرفه
      
      // Send push notification based on platform and target audience
      // إرسال الإشعار الفوري حسب المنصة (ويب أو موبايل) والجمهور المستهدف
      bool sent = false; // متغير لتتبع نجاح الإرسال
      
      // Use Cloud Functions on web, direct FCM on mobile
      // استخدام Cloud Functions على الويب، و FCM مباشرة على الموبايل
      if (kIsWeb) { // إذا كانت المنصة ويب
        // Web: Use Cloud Functions (works around CORS)
        // الويب: استخدام Cloud Functions (لتجاوز قيود CORS)
        switch (notification.targetAudience) { // حسب الجمهور المستهدف
          case 'all': // جميع المستخدمين
            sent = await _cloudFunctions.sendNotificationToAll( // إرسال لجميع المستخدمين
              title: notification.title, // عنوان الإشعار
              body: notification.body, // نص الإشعار
            );
            break;
          case 'doctors': // الأطباء
          case 'nurses': // الممرضين
          case 'patients': // المرضى
            sent = await _cloudFunctions.sendNotificationByRole( // إرسال حسب الدور
              role: notification.targetAudience, // الدور المستهدف
              title: notification.title, // عنوان الإشعار
              body: notification.body, // نص الإشعار
            );
            break;
        }
      } else { // إذا كانت المنصة موبايل
        // Mobile: Use direct FCM API
        // الموبايل: استخدام FCM API مباشرة
        switch (notification.targetAudience) { // حسب الجمهور المستهدف
          case 'all': // جميع المستخدمين
            sent = await _fcmService.sendNotificationToAll( // إرسال لجميع المستخدمين
              title: notification.title, // عنوان الإشعار
              body: notification.body, // نص الإشعار
              data: {'notificationId': docId}, // بيانات إضافية (معرف الإشعار)
            );
            break;
          case 'doctors': // الأطباء
          case 'nurses': // الممرضين
          case 'patients': // المرضى
            sent = await _fcmService.sendNotificationByRole( // إرسال حسب الدور
              role: notification.targetAudience, // الدور المستهدف
              title: notification.title, // عنوان الإشعار
              body: notification.body, // نص الإشعار
              data: {'notificationId': docId}, // بيانات إضافية (معرف الإشعار)
            );
            break;
        }
      }
      
      // Update status based on send result - تحديث حالة الإشعار حسب نتيجة الإرسال
      await updateNotificationStatus(docId, sent ? 'sent' : 'failed'); // 'sent' إذا نجح، 'failed' إذا فشل
      
      return docId; // إرجاع معرف الإشعار المُنشأ
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to create notification: $e'; // رمي استثناء مع رسالة الخطأ
    }
  }

  // Update Notification Status - تحديث حالة الإشعار
  // دالة لتحديث حالة إشعار معين (مثل: pending, sent, failed)
  Future<void> updateNotificationStatus(String id, String status) async {
    try {
      await _firestoreService.updateDocument(_collection, id, {'status': status}); // تحديث حقل status في المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update notification status: $e'; // رمي استثناء مع رسالة الخطأ
    }
  }

  // Delete Notification - حذف إشعار
  // دالة لحذف إشعار معين من قاعدة البيانات
  Future<void> deleteNotification(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id); // حذف المستند من Firestore
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to delete notification: $e'; // رمي استثناء مع رسالة الخطأ
    }
  }
}
