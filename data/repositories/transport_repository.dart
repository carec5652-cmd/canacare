// استيراد نموذج بيانات طلب النقل - لتعريف بنية بيانات طلب النقل
import 'package:admin_can_care/data/models/transport_request_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';
// استيراد Cloud Firestore - للوصول لنوع Query وبناء الاستعلامات المعقدة
import 'package:cloud_firestore/cloud_firestore.dart';

// Transport Repository - مستودع طلبات النقل
// يدير جميع عمليات طلبات النقل (الإنشاء، القراءة، التحديث، التعيين، الإكمال)
class TransportRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final String _collection = 'transportRequests'; // اسم مجموعة طلبات النقل في Firestore

  // Stream Transport Requests - تدفق طلبات النقل
  // دالة تُرجع تدفقاً من قائمة طلبات النقل مع إمكانية الفلترة حسب الحالة
  Stream<List<TransportRequestModel>> streamTransportRequests({String? status}) {
    return _firestoreService.streamCollection( // الحصول على تدفق المجموعة
      _collection, // اسم المجموعة
      queryBuilder: (query) { // بناء الاستعلام
        Query q = query; // البداية: استعلام بدون ترتيب
        
        // Apply filters WITHOUT orderBy to avoid index requirement
        // تطبيق الفلاتر بدون orderBy لتجنب متطلبات الفهرسة
        if (status != null && status.isNotEmpty) { // إذا كانت هناك حالة محددة
          q = q.where('status', isEqualTo: status); // فلترة حسب الحالة
        }
        
        return q; // إرجاع الاستعلام
      },
    ).map((snapshot) { // تحويل البيانات
      final docs = snapshot.docs // تحويل جميع المستندات
          .map((doc) => TransportRequestModel.fromMap( // من Map إلى TransportRequestModel
              doc.data() as Map<String, dynamic>, doc.id))
          .toList(); // تحويل إلى قائمة
      
      // Sort in memory instead of Firestore - الترتيب في الذاكرة بدلاً من Firestore
      // لتجنب الحاجة لإنشاء فهرس مركب في Firestore
      docs.sort((a, b) => b.requestedAt.compareTo(a.requestedAt)); // ترتيب تنازلي حسب تاريخ الطلب
      return docs; // إرجاع القائمة المرتبة
    });
  }

  // Get Transport Request by ID - الحصول على طلب نقل بالمعرف
  // دالة للحصول على بيانات طلب نقل واحد باستخدام معرفه
  Future<TransportRequestModel?> getTransportRequest(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id); // الحصول على المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return TransportRequestModel.fromMap( // تحويل البيانات
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get transport request: $e'; // رمي استثناء
    }
  }

  // Create Transport Request - إنشاء طلب نقل
  // دالة لإنشاء طلب نقل جديد في Firestore
  Future<String> createTransportRequest(TransportRequestModel request) async {
    try {
      return await _firestoreService.createDocument(_collection, request.toMap()); // إنشاء مستند وإرجاع معرفه
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to create transport request: $e'; // رمي استثناء
    }
  }

  // Update Transport Request - تحديث طلب نقل
  // دالة لتحديث بيانات طلب نقل موجود
  Future<void> updateTransportRequest(
      String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data); // تحديث المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update transport request: $e'; // رمي استثناء
    }
  }

  // Assign Driver - تعيين سائق
  // دالة لتعيين سائق لطلب نقل محدد وتغيير حالته إلى "assigned"
  Future<void> assignDriver(
      String requestId, String driverId, String driverName) async {
    try {
      await updateTransportRequest(requestId, { // تحديث طلب النقل
        'assignedDriverId': driverId, // معرف السائق المُعيَّن
        'assignedDriverName': driverName, // اسم السائق المُعيَّن
        'status': 'assigned', // تغيير الحالة إلى "تم التعيين"
      });
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to assign driver: $e'; // رمي استثناء
    }
  }

  // Complete Transport Request - إكمال طلب النقل
  // دالة لتعليم طلب نقل كمُكتمل مع تسجيل وقت الإكمال
  Future<void> completeRequest(String requestId) async {
    try {
      await updateTransportRequest(requestId, { // تحديث طلب النقل
        'status': 'completed', // تغيير الحالة إلى "مُكتمل"
        'completedAt': DateTime.now(), // تسجيل وقت الإكمال
      });
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to complete request: $e'; // رمي استثناء
    }
  }

  // Get Transport Statistics - الحصول على إحصائيات النقل
  // دالة للحصول على إحصائيات شاملة لجميع طلبات النقل (الكلي، قيد الانتظار، مُكتمل، مُلغى، قيد التنفيذ)
  Future<Map<String, int>> getTransportStats() async {
    try {
      final total = await _firestoreService.getCollectionCount(_collection); // عد جميع طلبات النقل
      final pending = await _firestoreService.getCollectionCount( // عد الطلبات قيد الانتظار
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'pending'),
      );
      final completed = await _firestoreService.getCollectionCount( // عد الطلبات المُكتملة
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'completed'),
      );
      final cancelled = await _firestoreService.getCollectionCount( // عد الطلبات المُلغاة
        _collection,
        queryBuilder: (q) => q.where('status', isEqualTo: 'cancelled'),
      );

      return { // إرجاع الإحصائيات في خريطة
        'total': total, // إجمالي الطلبات
        'pending': pending, // قيد الانتظار
        'completed': completed, // مُكتملة
        'cancelled': cancelled, // مُلغاة
        'inProgress': total - pending - completed - cancelled, // قيد التنفيذ (الباقي بعد طرح الحالات الأخرى)
      };
    } catch (e) { // في حالة حدوث خطأ
      return { // إرجاع إحصائيات فارغة (صفر)
        'total': 0,
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
        'inProgress': 0,
      };
    }
  }
}

