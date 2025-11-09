// استيراد نموذج بيانات المريض - لتعريف بنية بيانات المريض
import 'package:admin_can_care/data/models/patient_model.dart';
// استيراد خدمة Firestore - للتعامل مع قاعدة البيانات
import 'package:admin_can_care/data/services/firestore_service.dart';
// استيراد Cloud Firestore - للوصول لنوع Query وبناء الاستعلامات المعقدة
import 'package:cloud_firestore/cloud_firestore.dart';

// Patient Repository - مستودع المرضى
// يدير جميع عمليات المرضى (الإنشاء، القراءة، التحديث، الحذف، البحث)
class PatientRepository {
  final FirestoreService _firestoreService = FirestoreService(); // مثيل خدمة Firestore
  final String _collection = 'patients'; // اسم مجموعة المرضى في Firestore

  // Get All Patients - الحصول على جميع المرضى
  // دالة للحصول على قائمة جميع المرضى من Firestore مرتبة حسب تاريخ الإنشاء
  Future<List<PatientModel>> getAllPatients() async {
    try {
      final snapshot = await _firestoreService.queryCollection( // استعلام المجموعة
        _collection, // اسم المجموعة
        queryBuilder: (query) => query.orderBy('createdAt', descending: true), // ترتيب تنازلي حسب تاريخ الإنشاء
      );
      return snapshot.docs // تحويل المستندات
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // من Map إلى PatientModel
          .toList(); // إرجاع قائمة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get patients: $e'; // رمي استثناء
    }
  }

  // Stream Patients - تدفق المرضى
  // دالة تُرجع تدفقاً من قائمة المرضى مع إمكانية الفلترة حسب الطبيب أو الممرض أو الحالة
  Stream<List<PatientModel>> streamPatients({String? doctorId, String? nurseId, String? status}) {
    return _firestoreService // استدعاء خدمة Firestore
        .streamCollection( // الحصول على تدفق المجموعة
          _collection, // اسم المجموعة
          queryBuilder: (query) { // بناء الاستعلام بشروط ديناميكية
            Query q = query.orderBy('createdAt', descending: true); // البداية: ترتيب تنازلي
            if (doctorId != null && doctorId.isNotEmpty) { // إذا كان هناك معرف طبيب
              q = q.where('doctorId', isEqualTo: doctorId); // فلترة حسب الطبيب
            }
            if (nurseId != null && nurseId.isNotEmpty) { // إذا كان هناك معرف ممرض
              q = q.where('nurseId', isEqualTo: nurseId); // فلترة حسب الممرض
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
                  .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // تحويل كل مستند
                  .toList(), // إرجاع قائمة
        );
  }

  // Get Patient by ID - الحصول على مريض بالمعرف
  // دالة للحصول على بيانات مريض واحد باستخدام معرفه
  Future<PatientModel?> getPatient(String id) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, id); // الحصول على المستند
      if (!doc.exists) return null; // إذا لم يوجد المستند، إرجاع null
      return PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // تحويل البيانات وإرجاعها
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get patient: $e'; // رمي استثناء
    }
  }

  // Create Patient - إضافة مريض
  // دالة لإنشاء مريض جديد في Firestore
  Future<String> createPatient(PatientModel patient) async {
    try {
      return await _firestoreService.createDocument(_collection, patient.toMap()); // إنشاء مستند وإرجاع معرفه
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to create patient: $e'; // رمي استثناء
    }
  }

  // Update Patient - تحديث مريض
  // دالة لتحديث بيانات مريض موجود
  Future<void> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(_collection, id, data); // تحديث المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to update patient: $e'; // رمي استثناء
    }
  }

  // Delete Patient - حذف مريض
  // دالة لحذف مريض من قاعدة البيانات
  Future<void> deletePatient(String id) async {
    try {
      await _firestoreService.deleteDocument(_collection, id); // حذف المستند
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to delete patient: $e'; // رمي استثناء
    }
  }

  // Get Patients Count - عد المرضى
  // دالة للحصول على عدد المرضى الكلي أو حسب حالة معينة
  Future<int> getPatientsCount({String? status}) async {
    try {
      return await _firestoreService.getCollectionCount( // عد المستندات في المجموعة
        _collection, // اسم المجموعة
        queryBuilder: status != null ? (query) => query.where('status', isEqualTo: status) : null, // فلترة اختيارية حسب الحالة
      );
    } catch (e) { // في حالة حدوث خطأ
      return 0; // إرجاع 0
    }
  }

  // Get Patients by Doctor - الحصول على مرضى طبيب معين
  // دالة للحصول على جميع المرضى المُسندين لطبيب محدد
  Future<List<PatientModel>> getPatientsByDoctor(String doctorId) async {
    try {
      final snapshot = await _firestoreService.queryCollection( // استعلام المجموعة
        _collection, // اسم المجموعة
        queryBuilder: (query) => query.where('doctorId', isEqualTo: doctorId), // فلترة حسب معرف الطبيب
      );
      return snapshot.docs // تحويل المستندات
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // من Map إلى PatientModel
          .toList(); // إرجاع قائمة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get patients by doctor: $e'; // رمي استثناء
    }
  }

  // Get Patients by Nurse - الحصول على مرضى ممرض معين
  // دالة للحصول على جميع المرضى المُسندين لممرض محدد
  Future<List<PatientModel>> getPatientsByNurse(String nurseId) async {
    try {
      final snapshot = await _firestoreService.queryCollection( // استعلام المجموعة
        _collection, // اسم المجموعة
        queryBuilder: (query) => query.where('nurseId', isEqualTo: nurseId), // فلترة حسب معرف الممرض
      );
      return snapshot.docs // تحويل المستندات
          .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // من Map إلى PatientModel
          .toList(); // إرجاع قائمة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to get patients by nurse: $e'; // رمي استثناء
    }
  }

  // Search Patients - البحث عن المرضى
  // دالة للبحث عن المرضى حسب الاسم أو التشخيص أو رقم الهاتف
  Future<List<PatientModel>> searchPatients(String searchTerm) async {
    try {
      final snapshot = await _firestoreService.queryCollection(_collection); // الحصول على جميع المستندات
      final patients = // تحويل المستندات إلى قائمة PatientModel
          snapshot.docs
              .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

      // Simple client-side search - بحث على جانب العميل (لأن Firestore لا يدعم البحث النصي الكامل)
      return patients.where((patient) { // فلترة النتائج
        final term = searchTerm.toLowerCase(); // تحويل نص البحث للأحرف الصغيرة
        return patient.name.toLowerCase().contains(term) || // البحث في الاسم
            patient.diagnosis.toLowerCase().contains(term) || // البحث في التشخيص
            (patient.phone?.toLowerCase().contains(term) ?? false); // البحث في رقم الهاتف (إذا وُجد)
      }).toList(); // إرجاع القائمة المفلترة
    } catch (e) { // في حالة حدوث خطأ
      throw 'Failed to search patients: $e'; // رمي استثناء
    }
  }
}
