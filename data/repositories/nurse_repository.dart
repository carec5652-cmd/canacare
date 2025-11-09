// استيراد نموذج بيانات الممرض - لتعريف بنية بيانات الممرض
import 'package:admin_can_care/data/models/nurse_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';
// استيراد Cloud Firestore - للوصول لنوع Query وبناء الاستعلامات المعقدة
import 'package:cloud_firestore/cloud_firestore.dart';

// Nurse Repository - مستودع الممرضين
// يدير جميع عمليات الممرضين (الإنشاء، القراءة، التحديث، الحذف، البحث)
class NurseRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final String _collection = 'nurses'; // اسم مجموعة الممرضين في Firestore

  // Get All Nurses - الحصول على جميع الممرضين
  // دالة للحصول على قائمة جميع الممرضين من Firestore مرتبة حسب تاريخ الإنشاء
  Future<List<NurseModel>> getAllNurses() async {
    try {
      final snapshot = await _firestoreService.queryCollection( // استعلام المجموعة
        _collection, // اسم المجموعة
        queryBuilder: (query) => query.orderBy('createdAt', descending: true), // ترتيب تنازلي حسب تاريخ الإنشاء
      );
      return snapshot.docs // تحويل المستندات
          .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // من Map إلى NurseModel
          .toList(); // إرجاع قائمة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get nurses: $e'; // رمي استثناء
    }
  }

  // Stream Nurses - تدفق الممرضين
  // دالة تُرجع تدفقاً من قائمة الممرضين مع إمكانية الفلترة حسب القسم أو الحالة
  Stream<List<NurseModel>> streamNurses({String? department, String? status}) {
    return _firestoreService // استدعاء خدمة Firestore
        .streamCollection( // الحصول على تدفق المجموعة
          _collection, // اسم المجموعة
          queryBuilder: (query) { // بناء الاستعلام بشروط ديناميكية
            Query q = query.orderBy('createdAt', descending: true); // البداية: ترتيب تنازلي
            if (department != null && department.isNotEmpty) { // إذا كان هناك قسم محدد
              q = q.where('department', isEqualTo: department); // فلترة حسب القسم
            }
            if (status != null && status.isNotEmpty) { // إذا كانت هناك حالة محددة
              q = q.where('status', isEqualTo: status); // فلترة حسب الحالة
            }
            return q; // إرجاع الاستعلام المُعدّل
          },
        )
        .map( // تحويل البيانات
          (snapshot) =>
              snapshot.docs // جميع المستندات
                  .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // تحويل كل مستند
                  .toList(), // إرجاع قائمة
        );
  }

  // Get Nurse by ID - الحصول على ممرض بالمعرف
  // دالة للحصول على بيانات ممرض واحد باستخدام معرفه
  Future<NurseModel?> getNurse(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id); // الحصول على المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات وإرجاعها
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get nurse: $e'; // رمي استثناء
    }
  }

  // Create Nurse - إضافة ممرض
  // دالة لإنشاء ممرض جديد في Firestore
  Future<String> createNurse(NurseModel nurse) async {
    try {
      return await _firestoreService.createDocument(_collection, nurse.toMap()); // إنشاء مستند وإرجاع معرفه
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to create nurse: $e'; // رمي استثناء
    }
  }

  // Update Nurse - تحديث ممرض
  // دالة لتحديث بيانات ممرض موجود
  Future<void> updateNurse(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data); // تحديث المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update nurse: $e'; // رمي استثناء
    }
  }

  // Delete Nurse - حذف ممرض
  // دالة لحذف ممرض من قاعدة البيانات
  Future<void> deleteNurse(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id); // حذف المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to delete nurse: $e'; // رمي استثناء
    }
  }

  // Get Nurses Count - عد الممرضين
  // دالة للحصول على عدد الممرضين الكلي أو حسب حالة معينة
  Future<int> getNursesCount({String? status}) async {
    try {
      return await _firestoreService.getCollectionCount( // عد المستندات في المجموعة
        _collection, // اسم المجموعة
        queryBuilder: status != null ? (query) => query.where('status', isEqualTo: status) : null, // فلترة اختيارية حسب الحالة
      );
    } catch (e) { // في حالة حدوث خطأ
      return 0; // إرجاع 0
    }
  }

  // Search Nurses - البحث عن الممرضين
  // دالة للبحث عن الممرضين حسب الاسم أو القسم أو البريد الإلكتروني
  Future<List<NurseModel>> searchNurses(String searchTerm) async {
    try {
      final snapshot = await _firestoreService.queryCollection(_collection); // الحصول على جميع المستندات
      final nurses = // تحويل المستندات إلى قائمة NurseModel
          snapshot.docs
              .map((doc) => NurseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

      // Simple client-side search - بحث على جانب العميل (لأن Firestore لا يدعم البحث النصي الكامل)
      return nurses.where((nurse) { // فلترة النتائج
        final term = searchTerm.toLowerCase(); // تحويل نص البحث للأحرف الصغيرة
        return nurse.name.toLowerCase().contains(term) || // البحث في الاسم
            nurse.department.toLowerCase().contains(term) || // البحث في القسم
            (nurse.email.toLowerCase().contains(term)); // البحث في البريد الإلكتروني
      }).toList(); // إرجاع القائمة المفلترة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to search nurses: $e'; // رمي استثناء
    }
  }
}
