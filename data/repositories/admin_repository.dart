import 'package:admin_can_care/data/models/admin_model.dart';
import 'package:admin_can_care/data/services/firestore_service.dart';

// Admin Repository
// مستودع المشرفين
class AdminRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'admins';

  // Get Admin by ID
  // الحصول على بيانات المشرف بالمعرف
  Future<AdminModel?> getAdmin(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, uid);
      if (!doc.exists) return null;
      return AdminModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw 'Failed to get admin: $e';
    }
  }

  // Update Admin
  // تحديث بيانات المشرف
  Future<void> updateAdmin(String uid, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, uid, data);
    } catch (e) {
      throw 'Failed to update admin: $e';
    }
  }

  // Stream Admin
  // تدفق بيانات المشرف
  Stream<AdminModel?> streamAdmin(String uid) {
    return _firestoreService.streamDocument(_collection, uid).map((doc) {
      if (!doc.exists) return null;
      return AdminModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // Update Preferences
  // تحديث التفضيلات
  Future<void> updatePreferences(String uid, {String? locale, String? theme}) async {
    final data = <String, dynamic>{};
    if (locale != null) data['preferredLocale'] = locale;
    if (theme != null) data['preferredTheme'] = theme;
    await updateAdmin(uid, data);
  }
}
