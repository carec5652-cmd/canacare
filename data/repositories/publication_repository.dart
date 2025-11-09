// استيراد نموذج بيانات المنشور - لتعريف بنية بيانات المنشور
import 'package:admin_can_care/data/models/publication_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';
// استيراد Cloud Firestore - للوصول لنوع Query وبناء الاستعلامات المعقدة
import 'package:cloud_firestore/cloud_firestore.dart';

// Publication Repository - مستودع المنشورات
// يدير جميع عمليات المنشورات (الإنشاء، القراءة، التحديث، الحذف)
class PublicationRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final String _collection = 'publications'; // اسم مجموعة المنشورات في Firestore

  // Stream Publications - تدفق المنشورات
  // دالة تُرجع تدفقاً من قائمة المنشورات مع إمكانية الفلترة حسب الرؤية (عام/خاص)
  Stream<List<PublicationModel>> streamPublications({String? visibility}) {
    return _firestoreService // استدعاء خدمة Firestore
        .streamCollection( // الحصول على تدفق المجموعة
          _collection, // اسم المجموعة
          queryBuilder: (query) { // بناء الاستعلام
            Query q = query.orderBy('createdAt', descending: true); // ترتيب تنازلي حسب تاريخ الإنشاء
            if (visibility != null && visibility.isNotEmpty) { // إذا كان هناك فلتر رؤية
              q = q.where('visibility', isEqualTo: visibility); // فلترة حسب الرؤية
            }
            return q; // إرجاع الاستعلام المُعدّل
          },
        )
        .map( // تحويل البيانات
          (snapshot) =>
              snapshot.docs // جميع المستندات
                  .map( // تحويل كل مستند
                    (doc) => PublicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id), // من Map إلى PublicationModel
                  )
                  .toList(), // إرجاع قائمة
        );
  }

  // Get Publication by ID - الحصول على منشور بالمعرف
  // دالة للحصول على بيانات منشور واحد باستخدام معرفه
  Future<PublicationModel?> getPublication(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id); // الحصول على المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return PublicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات وإرجاعها
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get publication: $e'; // رمي استثناء
    }
  }

  // Create Publication - إنشاء منشور
  // دالة لإنشاء منشور جديد في Firestore
  Future<String> createPublication(PublicationModel publication) async {
    try {
      return await _firestoreService.createDocument(_collection, publication.toMap()); // إنشاء مستند وإرجاع معرفه
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to create publication: $e'; // رمي استثناء
    }
  }

  // Update Publication - تحديث منشور
  // دالة لتحديث بيانات منشور موجود
  Future<void> updatePublication(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data); // تحديث المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update publication: $e'; // رمي استثناء
    }
  }

  // Delete Publication - حذف منشور
  // دالة لحذف منشور من قاعدة البيانات
  Future<void> deletePublication(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id); // حذف المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to delete publication: $e'; // رمي استثناء
    }
  }
}
