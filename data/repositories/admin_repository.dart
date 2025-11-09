// استيراد نموذج بيانات المشرف - لتعريف بنية بيانات المشرف
import 'package:admin_can_care/data/models/admin_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';

// Admin Repository - مستودع المشرفين
// يدير جميع عمليات المشرفين (القراءة، التحديث، تدفق البيانات)
class AdminRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final String _collection = 'admins'; // اسم مجموعة المشرفين في Firestore

  // Get Admin by ID - الحصول على بيانات المشرف بالمعرف
  // دالة للحصول على بيانات مشرف واحد باستخدام معرف المستخدم (UID)
  Future<AdminModel?> getAdmin(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, uid); // الحصول على المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return AdminModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات وإرجاعها
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get admin: $e'; // رمي استثناء
    }
  }

  // Update Admin - تحديث بيانات المشرف
  // دالة لتحديث بيانات مشرف موجود في Firestore
  Future<void> updateAdmin(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, uid, data); // تحديث المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update admin: $e'; // رمي استثناء
    }
  }

  // Stream Admin - تدفق بيانات المشرف
  // دالة تُرجع تدفقاً من بيانات مشرف واحد في الوقت الفعلي
  // تستمع للتغييرات في Firestore وتحدّث الواجهة تلقائياً
  Stream<AdminModel?> streamAdmin(String uid) {
    return _firestoreService.streamDocument(_collection, uid).map((doc) { // الاتصال بتدفق المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return AdminModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات
    });
  }

  // Update Preferences - تحديث التفضيلات
  // دالة لتحديث تفضيلات المشرف (اللغة والثيم)
  Future<void> updatePreferences(String uid, {String? locale, String? theme}) async {
    final data = <String, dynamic>{}; // إنشاء خريطة بيانات فارغة
    if (locale != null) data['preferredLocale'] = locale; // إضافة اللغة المفضلة إن وُجدت
    if (theme != null) data['preferredTheme'] = theme; // إضافة الثيم المفضل إن وُجد
    await updateAdmin(uid, data); // تحديث بيانات المشرف
  }
}
